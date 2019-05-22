var machine_cpu_price = 0.62
var machine_ram_gb_price = 0.22
var disk_boot_gb_price = 0.01
var disk_standard_gb_price = 0.01
var disk_custom_gb_price = 0.01
var disk_custom_iops_price = 0.005
var disk_archive_gb_price = 0.0028
// var vm_os_price = 1.1112
var cloud_space_price = 0.125
// var bw_internet_price = 1.0416
var image_prices = {
  'Windows 2012r2 Standard': 1.1111,
  'Windows 2016 R1 new': 1.1111,
}
var snapshots_in_pack = 10;
var snapshots_pack_price_multiptier = 0.2;

// скидки на отдельные конфигурации
var discounts = [
  {
    cpu: 1,
    ram: 0.5,
    value: 0.94863,
  },
  {
    cpu: 1,
    ram: 1,
    value: 0.260912,
  },
  {
    cpu: 1,
    ram: 2,
    value: 0.217767,
  },
  {
    cpu: 1,
    ram: 4,
    value: 0.160185,
  },
  {
    cpu: 1,
    ram: 8,
    value: 0.108893,
  },
  {
    cpu: 2,
    ram: 1,
    value: 0.517694,
  },
  {
    cpu: 2,
    ram: 2,
    value: 0.448578,
  },
  {
    cpu: 2,
    ram: 4,
    value: 0.359931,
  },
  {
    cpu: 2,
    ram: 8,
    value: 0.265277,
  },
  {
    cpu: 4,
    ram: 2,
    value: 0.620909,
  },
  {
    cpu: 4,
    ram: 4,
    value: 0.54241,
  },
  {
    cpu: 4,
    ram: 8,
    value: 0.437565,
  },
  {
    cpu: 4,
    ram: 16,
    value: 0.317824,
  },
  {
    cpu: 6,
    ram: 12,
    value: 0.461259,
  },
  {
    cpu: 6,
    ram: 18,
    value: 0.385669,
  },
  {
    cpu: 8,
    ram: 16,
    value: 0.473106,
  },
];

function execute_billing_code(usage_params) {
  'use strict'

  let result = [];

  let snapshots = calc_snapshots_count(usage_params);

  usage_params.map((item) => {
    if (item.cloud_spaces) {
      result.push(parse_cloud_space(item));
    }

    if (item.machines) {
      result.push(parse_machine(item));
    }

    if (item.disks) {
      result.push(parse_disk(item));
    }
  });

  var snapshots_billing = calc_snapshots_billing(result, snapshots);
  if (snapshots_billing) {
    result.map((item) => {
      if (item.resource == 'machine') {
        item.prices.snapshot_packs = snapshots_billing;
      }
    });
  }

  result.map((ele) => {
    ele.start_at = usage_params[0].start_at;
    ele.end_at = usage_params[0].end_at;
    ele.client_id = usage_params[0].client_id;
    ele.product_id = usage_params[0].product_id;
    ele.product_instance_id = usage_params[0].product_instance_id;
  })

  return result;
}

function calc_snapshots_count(usage_params) {
  'use strict';

  let snapshots = 0;

  usage_params.map((item) => {
    if (item.snapshots) {
      snapshots += item.snapshots.resources_count;
    }
  });

  return snapshots;
}

function calc_snapshots_billing(billing_resources, snapshots) {
  var snapshot_packs = Math.ceil(snapshots / (snapshots_in_pack * 1.0)) || 0;
  if (!snapshot_packs) return;
  total_price = 0;
  billing_resources.map((bl) => {
    Object.keys(bl.prices).map((unit_name) => {
      var unit = bl.prices[unit_name];
      total_price += unit.price;
    })
  });

  return {
    count: snapshot_packs,
    price: total_price * snapshots_pack_price_multiptier * snapshot_packs,
    currency: 'rub',
  }
}

function parse_cloud_space(usage) {
  'use strict';

  let result = {
    id: usage.resource_id,
    resource: 'cloud_space',
    prices: {
      ip_address: {
        count: usage.cloud_spaces.resources_count,
        price: usage.cloud_spaces.resources_count * cloud_space_price,
        currency: 'rub',
      },
    },
  };

  return result;
}

function parse_disk(usage) {
  'use strict';

  let result = {
    id: usage.resource_id,
    resource: 'disk',
    prices: {},
  }

  if (usage.disks.disk_type == 'standard') {
    if (usage.disks.cloud_type == 'B') {
      result.prices = {
        size: {
          count: usage.disks.size,
          price: usage.disks.size * disk_boot_gb_price,
          currency: 'rub',
        },
      };
    } else {
      result.prices = {
        size: {
          count: usage.disks.size,
          price: usage.disks.size * disk_standard_gb_price,
          currency: 'rub',
        },
      };
    }
  } else if (usage.disks.disk_type == 'archive') {
    result.prices = {
      size: {
        count: usage.disks.size,
        price: usage.disks.size * disk_archive_gb_price,
        currency: 'rub',
      },
    };
  } else if (usage.disks.disk_type == 'custom') {
    result.prices = {
      size: {
        count: usage.disks.size,
        price: usage.disks.size * disk_custom_gb_price,
        currency: 'rub',
      },
      iops_sec: {
        count: usage.disks.iops_sec,
        price: usage.disks.iops_sec * disk_custom_iops_price,
        currency: 'rub',
      },
    };
  }

  return result;
}

function parse_machine(usage) {
  'use strict';

  let priceMultiplier = 10**4;
  let discountMultiplier = 1;

  let discount = discounts.filter((ele) => {
    if (ele.cpu == usage.machines.vcpus && ele.ram == usage.machines.memory / 1024) {
      return true;
    }
  })[0];

  if (discount) {
    discountMultiplier = 1 - discount.value;
  }

  let bigCpuPrice = machine_cpu_price * priceMultiplier * discountMultiplier;
  let bigRamPrice = machine_ram_gb_price * priceMultiplier * discountMultiplier;


  let cpuTotalPrice = Math.floor(usage.machines.vcpus * bigCpuPrice) / priceMultiplier;
  let ramTotalPrice = Math.floor(usage.machines.memory * bigRamPrice / 1024) / priceMultiplier;

  let result = {
    id: usage.resource_id,
    resource: 'machine',
    prices: {
      cpu: {
        count: usage.machines.vcpus,
        price: cpuTotalPrice,
        currency: 'rub',
      },
      ram: {
        count: usage.machines.memory,
        price: ramTotalPrice,
        currency: 'rub',
      },
    },
  };

  if (usage.machines.image_name) {
    var price = image_prices[usage.machines.image_name];
    if (price) {
      result.prices[usage.machines.image_name] = {
        count: 1,
        price: price,
        currency: 'rub',
      }
    }
  }

  return result;
}

FactoryBot.define do
  factory :billing_code_version do
    product_instance
    lang 'js'
    code "function execute_billing_code(usage_params) {

            let cpu_usage = usage_params.cpu;
            let memory_usage = usage_params.memory;

            let start_at = usage_params.start_at;
            let end_at = usage_params.end_at;

            // some code

            return { cpu: { count: 10, price: 120, currency: 'rub' },  memory: { count: 4000, price: 100, currency: 'rub' } }

          };"

    trait(:with_code_by_production) do
      code "function execute_billing_code(usage_params) {\n  var machine_cpu_price = 0.3889\n  var machine_ram_gb_price = 0.2917\n  var disk_boot_gb_price = 0.008\n  var disk_standard_gb_price = 0.008\n  var disk_custom_gb_price = 0.0103\n  var disk_custom_iops_price = 0.0054\n  var disk_archive_price = 0.0022\n  // var vm_os_price = 1.1112\n  var cloud_space_price = 0.2084\n  // var bw_internet_price = 1.0417\n\n\n  let result = {\n    start_at: usage_params.start_at,\n    end_at: usage_params.end_at,\n    client_id: usage_params.client_id,\n    product_instance_id: usage_params.product_instance_id,\n  }\n\n  if (usage_params.machines) {\n    result.cpu = {\n      count: usage_params.machines.vcpus,\n      price: usage_params.machines.vcpus * machine_cpu_price,\n      currency: 'rub',\n    }\n\n    result.ram = {\n      count: usage_params.machines.memory,\n      price: usage_params.machines.memory * machine_ram_gb_price / 1024,\n      currency: 'rub',\n    }\n\n    result.boot_disk = {\n      count: usage_params.machines.boot_disk_size,\n      price: usage_params.machines.boot_disk_size * disk_boot_gb_price,\n      currency: 'rub',\n    }\n  }\n\n  return result;\n};\n"
    end
  end
end

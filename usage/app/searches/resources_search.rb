# frozen_string_literal: true

class ResourcesSearch < Searchlight::Search
  SEARCH_BY_IDS = %i[product_ids partner_ids resource_ids].freeze

  def base_query
    Resource
  end

  def options
    super.tap do |opts|
      opts[:hourly] = 'usages.period_start' if opts[:hourly].present?
      opts[:sort_by] = ['resources.kind', 'resources.client_id', 'resources.product_instance_id', 'resources.product_id', 'resources.image_name'] # default sort_by
      opts[:sort_by] << ['resources.', opts[:sort_key]].join if opts[:sort_key].present? # if requested additional grouping
      SEARCH_BY_IDS.each do |field_name|
        opts[:sort_by] << ['resources.', field_name.to_s.chop].join if opts[field_name].present?
      end
      opts[:sort_by] = opts[:sort_by].uniq # in case if requested search_by_ids grouping matches defaults or passed sort_key
    end
  end

  def search_resource_ids
    query.where(resource_id: resource_ids)
  end

  def search_client_ids
    query.where(client_id: client_ids)
  end

  def search_product_ids
    query.where(product_id: product_ids)
  end

  def search_partner_ids
    query.where(partner_id: partner_ids)
  end

  def search_product_instance_ids
    query.where(product_instance_id: product_instance_ids)
  end

  def search_from_to
    group_by_string = options.slice(:sort_by, :hourly).values.join(', ')

    # distinct join?
    # +min(usages.period_end)+ might decrease performance. All usages per period start have equal +period_end+.
    query.joins(:payloads)
         .where('usages.period_start >= ? AND usages.period_end <= ?', options[:from_to].first, options[:from_to].last)
         .select("
           #{options[:hourly].present? ? [group_by_string, 'min(usages.period_end) AS period_end'].join(', ') : group_by_string},
           COUNT(DISTINCT resources.id) AS resources_count,
           SUM((usages.chargable->>'vcpus')::integer) as vcpus,
           SUM((usages.chargable->>'memory')::integer) as memory,
           SUM((usages.chargable->>'size')::integer) as size,
           SUM((usages.chargable->>'iops_sec')::integer) as iops_sec,
           SUM((usages.chargable->>'bytes_sec')::integer) as bytes_sec,
           (array_agg((usages.chargable->>'disk_type')::text))[1] as disk_type,
           (array_agg((usages.chargable->>'cloud_type')::text))[1] as cloud_type
         ").group(group_by_string)
  end

  def search_speed
    group_by_string = options.slice(:sort_by).values.join(', ')

    # Join last finished event
    # TODO: proper index
    join_sql = <<-SQL
      INNER JOIN "events" ON "events"."id" = (
        SELECT id FROM "events"
        WHERE "events"."resource_id" = "resources"."id" AND "events"."finished_at" <= '#{options[:speed].utc.strftime('%Y-%m-%d %T.%L')}'
        ORDER BY "events"."name" DESC, "events"."finished_at" DESC
        LIMIT 1
      )
    SQL

    query.active
         .joins(join_sql)
         .distinct
         .select("
           #{group_by_string},
           COUNT(DISTINCT resources.id) AS resources_count,
           SUM((events.resource_parameters->>'vcpus')::integer) as vcpus,
           SUM((events.resource_parameters->>'memory')::integer) as memory,
           SUM((events.resource_parameters->>'size')::integer) as size,
           SUM((events.resource_parameters->>'iops_sec')::integer) as iops_sec,
           SUM((events.resource_parameters->>'bytes_sec')::integer) as bytes_sec,
           (array_agg((events.resource_parameters->>'disk_type')::text))[1] as disk_type,
           (array_agg((events.resource_parameters->>'cloud_type')::text))[1] as cloud_type
         ")
         .group(group_by_string)
  end
end

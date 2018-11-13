module GrapeMarkdown
  class Resource
    attr_reader :key, :name, :routes, :sample_generator

    def initialize(key, routes)
      @key              = key
      @name             = key.humanize
      @routes           = routes
      @sample_generator = SampleGenerator.new(self)
    end

    def title
      @title ||= name.titleize
    end

    def namespaced
      @namespaced ||= routes.group_by(&:namespace).map do |_, routes|
        Resource.new(name, routes)
      end
    end

    def paths
      @paths ||= routes.group_by(&:route_path_without_format).map do |_, routes|
        Resource.new(name, routes)
      end
    end

    def header
      # TODO: ???
      route = routes.first

      "#{title} #{route.route_type} [#{route.route_path_without_format}]"
    end

    def sample_request(pretty = true)
      sample_generator.request(pretty: pretty)
    end

    def sample_response(route, pretty = true)
      sample_generator.response(list: route.list?, pretty: pretty)
    end

    def unique_params
      # TODO: this is a hack, assuming that the resource has a POST or PUT
      # route that defines all of the parameters that would define the resource
      methods = %w(POST PUT)

      potential = routes.select do |route|
        methods.include?(route.request_method) && route.route_params.present?
      end

      if potential.present?
        potential.first.route_params
      else
        []
      end
    end

    def resource_binding
      binding
    end
  end
end

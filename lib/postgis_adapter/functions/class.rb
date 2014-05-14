module PostgisAdapter
  module Functions

    #
    # Class Methods
    #
    module ClassMethods

      #
      # Returns the closest record
      def closest_to(p, opts = {})
        srid = opts.delete(:srid) || 4326
        order("ST_Distance(#{default_geometry}, '#{p.as_ewkt}' )").first
      end

      #
      # Order by distance
      def close_to(p, opts = {})
        srid = opts.delete(:srid) || 4326
        order "ST_Distance(#{default_geometry}, '#{p.as_ewkt}' )"
      end

      def by_length opts = {}
        sort = opts.delete(:sort) || 'asc'
        order "ST_length(#{default_geometry}) #{sort}"        
      end

      def longest
        order("ST_length(geom) DESC").first
      end

      def contains(p, srid=4326)
        where "ST_Contains(#{default_geometry}, '#{p.as_ewkt}' )" 
      end

      def contain(p, srid=4326)
        where("ST_Contains(#{default_geometry}, '#{p.as_ewkt}' )").first
      end

      def by_area sort='asc'
        order "ST_Area(#{default_geometry}) #{sort}"
      end

      def by_perimeter sort='asc'
        order "ST_Perimeter(#{default_geometry}) #{sort}" 
      end

      def all_dwithin(other, margin=1)
        where "ST_DWithin(#{default_geometry}, '#{other.as_ewkt}', #{margin})"
      end

      def all_within(other)
        where "ST_Within(#{default_geometry}, '#{other.as_ewkt}' )"
      end

      def by_boundaries sort='asc'
        order "ST_Boundary(#{default_geometry}) #{sort}"
      end

    end

  end
end

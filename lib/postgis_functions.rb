# #
# PostGIS Adapter
#
#
# http://github.com/nofxx/postgis_adapter
#
# Thanks to the great Spatial Adapter by Guilhem Vellut
#
module PostgisFunctions

  # #
  # PostGis Manual:
  # #
  #http://postgis.refractions.net/documentation/manual-1.3/ch06.html
  #
  #
  # #
  # Measurement:
  #
  # ST_length(geometry)
  # ST_length_spheroid
  # length3d_spheroid
  #
  # ST_Area(geometry)
  # ST_perimeter(geometry) Returns the 2-dimensional perimeter of the geometry, if it is a polygon or multi-polygon.
  # ST_perimeter2d(geometry)   Returns the 2-dimensional perimeter of the geometry, if it is a polygon or multi-polygon.
  # ST_perimeter3d(geometry)
  #
  # ST_azimuth(geometry, geometry)
  # ST_Centroid(geometry)
  #
  #
  # #
  # Relationship:
  #
  # ST_Equals(geometry, geometry)   - Spatially equal
  #
  # ST_Distance(geometry, geometry) - Cartesian
  # ST_distance_sphere
  # ST_distance_spheroid
  # ST_max_distance Returns the largest distance between two line strings.
  #
  # ST_Intersects(geometry, geometry) - Do not call with a GeometryCollection as an argument
  # ST_Touches(geometry, geometry)
  # ST_Crosses(geometry, geometry)
  # ST_Within(geometry, geometry) - A has to be completely inside B.
  # ST_Contains(geometry, geometry)
  # ST_Covers(geometry, geometry)
  # ST_CoveredBy(geometry, geometry)- true if no point in Geometry B is outside Geometry A
  # ST_DWithin(geometry, geometry, float) - if geom is within dist(float)

  #x ST_Relate(geometry, geometry, intersectionPatternMatrix)
  #x ST_Disjoint(geometry, geometry)
  #x ST_Overlaps

  #
  # Returns 1 (TRUE)
  def construct_geometric_sql(type,geoms,options)

    tables = geoms.map do |t| {
      :class => t.class.to_s.downcase.pluralize,
      :uid =>  unique_identifier,
      :id => t[:id] }
    end

    fields = tables.map { |f| f[:uid] + ".geom" }       # W1.geom
    fields << options if options

    froms = tables.map { |f| "#{f[:class]} #{f[:uid]}"}  # streets W1
    wheres = tables.map { |f| "#{f[:uid]}.id = #{f[:id]}"} # W1.id = 5

    operation = type.to_s
    operation = operation.camelize unless operation =~ /spher|max|npoints/
    operation = "ST_#{operation}" unless operation =~ /th3d/
    join_method = " AND "

    sql =   "SELECT #{operation}(#{fields.join(",")}) FROM #{froms.join(",")} "
    sql <<  "WHERE #{wheres.join(join_method)}" if wheres
    p sql
    sql
  end

  def execute_geometrical_calculation(operation, subject, options) #:nodoc:
    value = connection.select_value(construct_geometric_sql(operation, subject, options))
    if value =~ /^\D/
      {"f" => false, "t" => true}[value]
    elsif value =~ /\./
      value.to_f
    else
      GeoRuby::SimpleFeatures::Geometry.from_hex_ewkb(value) rescue value.to_f
    end
  end

  def calculate(operation, subject, options = nil)
    subject = [subject] unless subject.respond_to?(:map)
    return execute_geometrical_calculation(operation, subject, options)
  end

  def unique_identifier
    @u_id ||= "W1"
    @u_id = @u_id.succ
  end

  # #
  #
  # COMMON GEOMETRICAL FUNCTIONS

  def spatially_equal?(other)
    calculate(:equals, [self, other])
  end

  def envelope
    calculate(:envelope, self)
  end

  def centroid
    calculate(:centroid, self)
  end

  def distance_to other
    calculate(:distance, [self, other])
  end

  def spherical_distance other
    calculate(:distance_sphere, [self, other])
  end

  def within? other
    calculate(:within, [self, other])
  end

  def contains? other
    calculate(:contains, [self, other])
  end

  def inside? other
    calculate(:covered_by, [self, other])
  end

  def outside? other
    !inside? other
  end
end

####
###
##
#
# POINT
#
#
#
#
module PointFunctions
  class << self

    def included base #:nodoc:
      base.extend ClassMethods

      class << base
        attr_accessor :has_geom_options
      end
    end

    module ClassMethods

      def has_point column="geom"
        include InstanceMethods
        has_geom_options = {:column => column}
      end

      def close_to(p, srid=4326)
        find(:all, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def closest_to(p, srid=4326)
        find(:first, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

    end

    module InstanceMethods
      include PostgisFunctions

      def in_bounds?(other,margin=0.5)
        calculate(:dwithin, [self, other], margin)
      end

      def azimuth other
        #TODO: return if not point/point
        calculate(:azimuth, [self, other])
      end
    end
  end
end

####
###
##
#
# LINESTRING
#
#
# Linear Referencing
#
# ST_line_interpolate_point
# ST_line_substring
# ST_line_locate_point
# ST_locate_along_measure
# ST_locate_between_measures
#
module LineStringFunctions

  class << self

    def included base #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def has_line_string column="geom"
        include InstanceMethods
      end

      def close_to(p, srid=4326)
        find(:first, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def by_size sort='asc'
        find(:all, :order => "length(geom) #{sort}" )
      end

      def longest
        find(:first, :order => "length(geom) DESC")
      end

    end

    module InstanceMethods
      include PostgisFunctions

      def length
        calculate(:length, self)
      end

      def num_points
        calculate(:npoints, self).to_i
      end# ST_NumPoints

      def start_point
        calculate(:start_point, self)
      end
      #ST_StartPoint

      def end_point
        calculate(:end_point, self)
      end
      #ST_EndPoint

      def intersects? other
        calculate(:intersects, [self, other])
      end

      def crosses? other
        calculate(:crosses, [self, other])
      end

      def touches? other
        calculate(:touches, [self, other])
      end

    end
  end
end

###
##
#
#
#
# Polygon
#
#
module PolygonFunctions

  class << self

    def included base #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def has_polygon column="geom"
        include InstanceMethods
      end

      def contains(p, srid=4326)
        find(:all, :conditions => ["ST_Contains(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))"])
      end

      def contain(p, srid=4326)
        find(:first, :conditions => ["ST_Contains(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))"])
      end

      def close_to(p, srid=4326)
        find(:all, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def closest_to(p, srid=4326)
        find(:first, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def by_size sort='asc'
        find(:all, :order => "Area(geom) #{sort}" )
      end

      def by_perimeter sort='asc'
        find(:all, :order => "Perimeter(geom) #{sort}" )
      end

    end

    module InstanceMethods
      include PostgisFunctions

      def area
        calculate(:area, self)
      end

      def perimeter
        calculate(:perimeter, self)
      end

      def perimeter3d
        calculate(:perimeter3d, self)
      end

      def overlaps? other
        calculate(:overlaps, [self, other])
      end

      def covers? other
        calculate(:covers, [self, other])
      end

      def touches? other
        calculate(:touches, [self, other])
      end

      def disjoint? other
        calculate(:disjoint, [self, other])
      end
    end
  end
end

#POINT(0 0)
#LINESTRING(0 0,1 1,1 2)
#POLYGON((0 0,4 0,4 4,0 4,0 0),(1 1, 2 1, 2 2, 1 2,1 1))
#MULTIPOINT(0 0,1 2)
#MULTILINESTRING((0 0,1 1,1 2),(2 3,3 2,5 4))
#MULTIPOLYGON(((0 0,4 0,4 4,0 4,0 0),(1 1,2 1,2 2,1 2,1 1)), ..)
#GEOMETRYCOLLECTION(POINT(2 3),LINESTRING((2 3,3 4)))

#BBOX OPERATORS
#These operators utilize indexes. They compare bounding boxes of 2 geometries
#A &< B (A overlaps or is to the left of B)
#A &> B (A overlaps or is to the right of B)
#A << B (A is strictly to the left of B)
#A >> B (A is strictly to the right of B)
#A &<| B (A overlaps B or is below B)
#A |&> B (A overlaps or is above B)
#A <<| B (A strictly below B)
#A |>> B (A strictly above B)
#A = B (A bbox same as B bbox)
#A @ B (A completely contained by B)
#A ~ B (A completely contains B)
#A && B (A and B bboxes interact)
#A ~= B - true if A and B geometries are binary equal?

#Accessors
#ST_Dimension
#ST_Dump
#ST_EndPoint
#ST_Envelope
#ST_ExteriorRing
#ST_GeometryN
#ST_GeometryType
#ST_InteriorRingN
#ST_IsClosed
#ST_IsEmpty
#ST_IsRing
#ST_IsSimple
#ST_IsValid
#ST_mem_size
#ST_M
#ST_NumGeometries
#ST_NumInteriorRings
#ST_NumPoints
#ST_npoints
#ST_PointN
#ST_SetSRID
#ST_StartPoint
#ST_Summary1
#ST_X
#ST_XMin,ST_XMax
#ST_Y
#YMin,YMax
#ST_Z
#ZMin,ZMax

#OUTPUT

#ST_AsBinary
#ST_AsText
#ST_AsEWKB
#ST_AsEWKT
#ST_AsHEXEWKB
#ST_AsGML
#ST_AsKML
#ST_AsSVG

#if Object.const_defined?("ActiveRecord")
# ActiveRecord::Base.send(:include, PostgisFunctions)
#end
#      def has_point(p)
#        p = [p] unless p.respond_to?(:each)
#        p.each { |p| geo_columns_add({:point => p}) }
#      end
#      def has_polygon(p)
#        geo_columns_add({:polygon => p})
#      end
#      def has_line_string(ln)
#      end
#class GeoRuby::SimpleFeatures::Point
#class GeoRuby::SimpleFeatures::LineString
#class GeoRuby::SimpleFeatures::Polygon
#class GeoRuby::SimpleFeatures::Geometry
#class GeoRuby::SimpleFeatures::MultiPoint
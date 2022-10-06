class BoundingBox
  attr_accessor :state_data, :state_names

  def initialize(state_names=[])
    @state_names = state_names || []
    load_states
  end

  def load_states
    data = YAML::load_file(File.join(__dir__, 'support/us_states.yml'))
    @state_data = data.select {|s| state_names.include?(s["name"])}
  end

  def calculate
    minX, minY, maxX, maxY = 0,0,0,0
    state_data.each do |state|
      bb = state["bounding_box"]
      points = [2,0,3,1].map{|x| bb[x]}
      points.each_with_index do |p, i|
        p = p.to_f
        case i
        when 0
          minX = p if p < minX || minX == 0
        when 1
          minY = p if p < minY || minY == 0
        when 2
          maxX = p if p > maxX || maxX == 0
        when 3
          maxY = p if p > maxY || maxY == 0
        end
      end
    end
    string = [minX, minY, maxX, maxY].join(',') 

    string == "0,0,0,0" ? nil : string

  end

end

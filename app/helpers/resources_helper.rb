module ResourcesHelper
  def resource_position(resource)
    return { top: 0, left: 0 } unless resource.location
    scale = 0.76 # Used for converting from inches (distance away from top left corner of space) to pixels (representing on the image)
    offset_top = 55 # Offset for extra border on the map around the actual space
    offset_left = 45
    { top: resource.location.first * scale + offset_top, left: resource.location.last * scale + offset_left }
  end
end

module ResourcesHelper
  def resource_position(resource)
    scale = 0.76 #Used for converting from inches (distance away from top left corner of space) to pixels (representing on the image)
    offsetTop = 55 #Offset for extra border on the map around the actual space
    offsetLeft = 45
    { top: resource.location.first * scale + offsetTop, left: resource.location.last * scale + offsetLeft }
  end
end
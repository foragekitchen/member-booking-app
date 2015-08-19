class ResourceLocation

  def convert_from_feet_to_inches(str)
    return Unit.new(str).convert_to("in").to_s.split(" ").first.to_i
  end

end
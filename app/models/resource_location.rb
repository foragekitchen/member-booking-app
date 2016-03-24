class ResourceLocation

  def convert_from_feet_to_inches(str)
    Unit.new(ActionView::Base.full_sanitizer.sanitize(str)).convert_to("in").to_s.split(" ").first.to_i
  end

end
module Day8
  module_function

  def parse_image(content, width, height)
    layer_size = width * height
    content.scan(/.{1,#{layer_size}}/)
  end

  def checksum(image)
    target = image.min_by { |layer| layer.count('0') }

    target.count('1') * target.count('2')
  end

  def combine_layers(layer1, layer2)
    layer1.chars.zip(layer2.chars).map do |parts|
      parts.find { |p| p < '2' } || '2'
    end.join
  end

  def final_image(image)
    image.reduce do |final, layer|
      combine_layers(final, layer)
    end.tr('012', ' X ')
  end
end

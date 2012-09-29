require 'RMagick'
include Magick

neuronsAmount = 1
frameSize = 2

class Neuron
	attr_accessor :colorArray

	def initialize
		@colorArray = Array.new
	end

	def adjust
end

#inicjalizacja tablic z neuronami
redNeuronsArray = Array.new
blueNeuronsArray = Array.new
greenNeuronsArray = Array.new

#wypełnienie tablic neuronami
neuronsAmount.times do
	redNeuronsArray.push(Neuron.new) 
	blueNeuronsArray.push(Neuron.new)
	greenNeuronsArray.push(Neuron.new)
end

#wypełnienie tablic neuronów losowymi wartościami
redNeuronsArray.each do |neuron|
	(0...frameSize*frameSize).each do |i|
		neuron.colorArray[i] = rand(65535)
	end
end
blueNeuronsArray.each do |neuron|
	(0...frameSize*frameSize).each do |i|
		neuron.colorArray[i] = rand(65535)
	end
end
greenNeuronsArray.each do |neuron|
	(0...frameSize*frameSize).each do |i|
		neuron.colorArray[i] = rand(65535)
	end
end

#wczytanie obrazka-zrodla
image = ImageList.new("chef.bmp")

#stworzenie obrazka docelowego
image2 = Image.new(image.columns, image.rows)

#przerysowanie jednego obrazka na drugi
(0..image.columns).each do |x|
	(0..image.rows).each do |y|
		pixel = image.pixel_color(x, y)
		image2.pixel_color(x, y, pixel)
	end
end

#zapisanie docelowego obrazka na dysku
image2.write("newimage.bmp")

print "i am done\n"
exit 
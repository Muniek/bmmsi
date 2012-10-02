require 'RMagick'
include Magick

startTime = Time.now


neuronsAmount = 5
frameSize = 4
learningFactor = 0.05
iterations = 1

class Neuron
	attr_accessor :colorArray

	def initialize
		@colorArray = Array.new
	end

	def adjust(image, pixelX, pixelY, frameSize, learningFactor, color)
		(0...frameSize).each do |i|
			(0...frameSize).each do |j|
				actualX = pixelX + i
				actualY = pixelY + j
				case color
				when 0
					pixelColor = image.pixel_color(actualY, actualX).red
				when 1
					pixelColor = image.pixel_color(actualY, actualX).green
				when 2
					pixelColor = image.pixel_color(actualY, actualX).blue
				end

				tempValue = colorArray[j+i*frameSize] + (pixelColor - colorArray[j+i*frameSize])*learningFactor
				if (tempValue < 0)
					tempValue = 0
				elsif tempValue > 65535
					tempValue = 65535
				else
					tempValue = tempValue
				end
				colorArray[j+i*frameSize] = tempValue
			end
		end
	end
end
#funkcja mierząca odległość pomiędzy ramką a neuronem
def measureFrameNeuronDistance(image, frameSize, frameX, frameY, neuron, color)
	distance = 0
	(0...frameSize).each do |loopX|
		(0...frameSize).each do |loopY|
			actualX=frameX+loopX
			actualY=frameY+loopY
			pixel = image.pixel_color(actualX, actualY)
			case color
			when 0
				pixelColor = pixel.red
			when 1
				pixelColor = pixel.green
			when 2
				pixelColor = pixel.blue
			end

			#pixelColor już mamy, neuron też przekazaliśmy jako wartość
			#neuronNumber = loopX+loopY*frameSize wyliczenie ktory element
			#w tablicy neuronu
			distance+=(pixelColor-neuron.colorArray[loopY+loopX*frameSize])**2
		end
	end
	distance
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
image = ImageList.new("testImage.bmp")

#tablice na zwycięskie neurony
bestRedNeuronsArray = Array.new
bestGreenNeuronsArray = Array.new
bestBlueNeuronsArray = Array.new


#zakładamy że szerokość i wysokość obrazka są podzielne przez wielkość ramki

iterations.times do
	bestRedNeuronsArray.clear
	bestGreenNeuronsArray.clear
	bestBlueNeuronsArray.clear

	3.times do |color|
		puts color
		
		case color
		when 0
			neuronsArray = redNeuronsArray
			bestNeuronsArray = bestRedNeuronsArray
		when 1
			neuronsArray = greenNeuronsArray
			bestNeuronsArray = bestGreenNeuronsArray
		when 2
			neuronsArray = blueNeuronsArray
			bestNeuronsArray = bestBlueNeuronsArray
		end

		i=0
		begin
			j=0
			begin
				#tutaj mamy już do dyspocyzji wybraną ramkę - teraz trzeba przejść
				#po wszystkich neuronach i znaleźć najbliższy
				smallestDistance = measureFrameNeuronDistance(image, frameSize, j, i, neuronsArray.first, color)
				bestNeuronId = 0

				bestNeuron = neuronsArray.first

				k=0
				neuronsArray.each do |neuron|
					actualDistance = measureFrameNeuronDistance(image, frameSize, j, i, neuron, color)	
					#jeżeli teraz zmierzony dystans jest najmniejszym do tej pory,
					#to zapamiętujemy go i zapamiętujemy id neuronu który go osiągnął
					if (actualDistance < smallestDistance)
						smallestDistance = actualDistance	
						bestNeuronId = k
						bestNeuron = neuron
					end		
					k+=1
				end
				#zapisanie najlepszego neuronu
				bestNeuronsArray.push(bestNeuronId)
							
				bestNeuron.adjust(image, i, j, frameSize, learningFactor, color)
				
				j+=frameSize
			end while j<image.columns
			i+=frameSize
		end while i<image.rows
	end
end

#stworzenie obrazka docelowego
image2 = Image.new(image.columns, image.rows)

newFrameArray = Array.new
#iteracja po framesize
height = image.rows/frameSize
width = image.columns/frameSize

puts image.rows
puts image.columns

puts height
puts width

(0...height).each do |x|
	(0...width).each do |y|
		#iterujemy po calej "kratce"
		(0...frameSize).each do |fX|
			(0...frameSize).each do |fY|
				bestRed = redNeuronsArray[bestRedNeuronsArray[y+x*width]].colorArray[fY+fX*frameSize]
				bestGreen = greenNeuronsArray[bestGreenNeuronsArray[y+x*width]].colorArray[fY+fX*frameSize]
				bestBlue = blueNeuronsArray[bestBlueNeuronsArray[y+x*width]].colorArray[fY+fX*frameSize]
				pixel = Pixel.new(bestRed, bestGreen, bestBlue)
				image2.pixel_color(y*frameSize+fY,x*frameSize+fX, pixel)
				print "["
				print x*frameSize+fX
				print "]["
				print y*frameSize+fY
				print "]"
				puts
			end
		end
	end
end


#zapisanie docelowego obrazka na dysku
image2.write("newimage.bmp")

print "done."


puts "Czas: #{Time.now - startTime} sek."

#exit 
class_name SustainNote extends Sprite2D

func draw_sustain_line(tex:Texture2D):
	var newLine = tex.get_image();
	newLine.rotate_90(CLOCKWISE);
	return ImageTexture.create_from_image(newLine);

extends Node

const EASES = [
	"linear",
	"sineIn",
	"sineOut",
	"sineInOut",
	"quadIn",
	"quadOut",
	"quadInOut",
	"cubicIn",
	"cubicOut",
	"cubicInOut",
	"quartIn",
	"quartOut",
	"quartInOut",
	"quintIn",
	"quintOut",
	"quintInOut",
	"expoIn",
	"expoOut",
	"expoInOut",
	"circIn",
	"circOut",
	"circInOut",
	"backIn",
	"backOut",
	"backInOut",
	"elasticIn",
	"elasticOut",
	"elasticInOut",
	"bounceIn",
	"bounceOut",
	"bounceInOut"
];
func ease_value(t, cam_ease):
	match cam_ease:
		"linear":
			return t;
			
		"sineIn":
			return 1.0 - cos((t * PI) / 2.0);
			
		"sineOut":
			return sin((t * PI) / 2.0);
			
		"sineInOut":
			return -(cos(PI * t) - 1.0) / 2.0;
			
		"quadIn":
			return t * t;
			
		"quadOut":
			return 1.0 - (1.0 - t) * (1.0 - t);
			
		"quadInOut":
			if t < 0.5:
				return 2.0 * t * t;
			return 1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0;
			
		"cubicIn":
			return t * t * t;
			
		"cubicOut":
			return 1.0 - pow(1.0 - t, 3.0);
			
		"cubicInOut":
			if t < 0.5:
				return 4.0 * t * t * t;
			return 1.0 - pow(-2.0 * t + 2.0, 3.0) / 2.0;
			
		"quartIn":
			return pow(t, 4);
			
		"quartOut":
			return 1.0 - pow(1.0 - t, 4);
			
		"quartInOut":
			if t < 0.5:
				return 8.0 * pow(t, 4);
			return 1.0 - pow(-2.0 * t + 2.0, 4) / 2.0;
			
		"quintIn":
			return pow(t, 5);
			
		"quintOut":
			return 1.0 - pow(1.0 - t, 5);
			
		"quintInOut":
			if t < 0.5:
				return 16.0 * pow(t, 5);
			return 1.0 - pow(-2.0 * t + 2.0, 5) / 2.0;
			
		"expoIn":
			return 0.0 if t == 0.0 else pow(2.0, 10.0 * t - 10.0);
			
		"expoOut":
			return 1.0 if t == 1.0 else 1.0 - pow(2.0, -10.0 * t);
			
		"expoInOut":
			if t == 0.0:
				return 0.0;
			if t == 1.0:
				return 1.0;
			if t < 0.5:
				return pow(2.0, 20.0 * t - 10.0) / 2.0;
			return (2.0 - pow(2.0, -20.0 * t + 10.0)) / 2.0;
			
		"circIn":
			return 1.0 - sqrt(1.0 - t * t);
			
		"circOut":
			return sqrt(1.0 - pow(t - 1.0, 2));
			
		"circInOut":
			if t < 0.5:
				return (1.0 - sqrt(1.0 - pow(2.0 * t, 2))) / 2.0;
			return (sqrt(1.0 - pow(-2.0 * t + 2.0, 2)) + 1.0) / 2.0;
			
		"backIn":
			var c1 = 1.70158;
			var c3 = c1 + 1.0;
			return c3 * t * t * t - c1 * t * t;
			
		"backOut":
			var c1 = 1.70158;
			var c3 = c1 + 1.0;
			return 1.0 + c3 * pow(t - 1.0, 3) + c1 * pow(t - 1.0, 2);
			
		"backInOut":
			var c2 = 2.5949095;
			if t < 0.5:
				return (pow(2.0 * t, 2) * ((c2 + 1.0) * 2.0 * t - c2)) / 2.0;
			return (pow(2.0 * t - 2.0, 2) * ((c2 + 1.0) * (t * 2.0 - 2.0) + c2) + 2.0) / 2.0;
			
		"elasticIn":
			if t == 0.0 or t == 1.0:
				return t;
			return -pow(2.0, 10.0 * t - 10.0) * sin((t * 10.0 - 10.75) * (2.0 * PI / 3.0));
			
		"elasticOut":
			if t == 0.0 or t == 1.0:
				return t;
			return pow(2.0, -10.0 * t) * sin((t * 10.0 - 0.75) * (2.0 * PI / 3.0)) + 1.0;
			
		"elasticInOut":
			if t == 0.0 or t == 1.0:
				return t;
			var c5 = (2.0 * PI) / 4.5;
			if t < 0.5:
				return -(pow(2.0, 20.0 * t - 10.0) * sin((20.0 * t - 11.125) * c5)) / 2.0;
			return (pow(2.0, -20.0 * t + 10.0) * sin((20.0 * t - 11.125) * c5)) / 2.0 + 1.0;
			
		"bounceOut":
			var n1 = 7.5625;
			var d1 = 2.75;
			
			if t < 1.0 / d1:
				return n1 * t * t;
			elif t < 2.0 / d1:
				t -= 1.5 / d1;
				return n1 * t * t + 0.75;
			elif t < 2.5 / d1:
				t -= 2.25 / d1;
				return n1 * t * t + 0.9375;
			else:
				t -= 2.625 / d1;
				return n1 * t * t + 0.984375;
				
		"bounceIn":
			return 1.0 - ease_value(1.0 - t, "bounceOut");
			
		"bounceInOut":
			if t < 0.5:
				return (1.0 - ease_value(1.0 - 2.0 * t, "bounceOut")) / 2.0;
			return (1.0 + ease_value(2.0 * t - 1.0, "bounceOut")) / 2.0;
			

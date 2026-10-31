class_name ChartLoader extends Node

func load_chart(song_chart, song_name, events_path = ""):
	if song_chart.has("codenameChart"):
		CodenameChart.apply(song_chart, song_name);
		CodenameChart.convert_codenameChart(song_chart, events_path);
		
	elif song_chart.has("song"):
		PsychChart.apply(song_chart);
		PsychChart.convert_pyschChart(song_chart, events_path);
		
	else:
		DefaultChart.apply(song_chart, events_path);
		

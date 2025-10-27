extends Node

func _ready() -> void:
	DiscordRPC.app_id = 1323692400736211005;
	DiscordRPC.large_image_text = "Another FNF Engine Made In Godot";
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system());
	DiscordRPC.refresh();
	
func update_discord_info(details = "", state = "In menus", large_image_text = "Another FNF Engine Made In Godot", icon = "", endTime = 0.0):
	DiscordRPC.details = details;
	DiscordRPC.state = state;
	DiscordRPC.large_image = "engine_logo";
	DiscordRPC.large_image_text = large_image_text;
	DiscordRPC.small_image = icon;
	DiscordRPC.small_image_text = "";
	if endTime > 0:
		DiscordRPC.end_timestamp = int(endTime);
	DiscordRPC.refresh();

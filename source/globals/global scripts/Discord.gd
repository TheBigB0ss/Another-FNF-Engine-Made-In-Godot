extends Node

var discord;

func _ready() -> void:
	discord = get_node_or_null("/root/DiscordRPC");
	
	if !Bootup.is_on_mobile && discord:
		discord.app_id = 1323692400736211005;
		discord.large_image_text = "Another FNF Engine Made In Godot";
		discord.start_timestamp = int(Time.get_unix_time_from_system());
		discord.refresh();

func update_discord_info(details = "", state = "In menus", large_image_text = "Another FNF Engine Made In Godot", endTime = 0.0):
	if !Bootup.is_on_mobile && discord:
		discord.details = details;
		discord.state = state;
		discord.large_image = "engine_logo";
		discord.large_image_text = large_image_text;
		discord.small_image = "";
		discord.small_image_text = "";
		if endTime > 0:
			discord.end_timestamp = int(endTime);
		discord.refresh();

extends Node

func _ready():
	pass

# {'plant': var plant, 'progress': var progress, 'time_left': var time_left, 'used_potions': var used_potions, 'weeds': var weeds}:
# {'plant': null, 'weeds': true}:
# {'inventory_item': var item}:
# {'title': var title}:
# {'description': var description}:
# {'title': var title, 'description': var description}:
# {'hide': true}:
signal tooltip(msg)

# {'selected': var item}:
# {'deselected': true}:
signal inventory_item(msg)
# no data
signal inventory_deselect

# {'type': var item_type, 'id': var item_id, 'animated': true, 'from_position': var from_position}:
# {'type': var item_type, 'id': var item_id, 'animated': true, 'from_position': var from_position, 'count': var count}:
# {'type': var item_type, 'id': var item_id, 'count': var count}:
# {'type': var item_type, 'id': var item_id}:
signal inventory_add(msg)

# {'amount': var amount}:
signal gems_add(msg)
# {'amount': var amount}:
signal gems_update(msg)

# true | false
signal show_achievements(show)
# true | false
signal show_journal(show)

# ???
signal mouse_area(msg)

# {'total_id': var total_id, 'total_add': var total_add}:
# {'diff_id': var diff_id, 'diff_add': var diff_add}:
# {'total_id': var total_id, 'total_add': var total_add, 'diff_id': var diff_id, 'diff_add': var diff_add}:
signal achievement(msg)

# no data
signal save_game
signal load_game
signal saved
signal menu_new_game
signal start_new_game
signal continue_game
signal exit_confirm
signal exit_confirm_close
signal show_main_menu

# no data
signal unlock_journal
# {'id': var page_id}:
signal unlock_journal_page(msg)
# {'id': var page_id}:
signal show_journal_page(msg)

# float
signal add_luck(x)

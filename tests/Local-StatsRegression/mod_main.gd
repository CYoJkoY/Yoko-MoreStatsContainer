extends Node
var checks = 0
var failures = []
func _ready():
    if OS.get_user_data_dir().find("Stats-Regression-Test") < 0: return
    if not OS.get_cmdline_args().has("--stats-regression"): return
    call_deferred("run_tests")
func check(ok, label):
    checks += 1
    if not ok: failures.append(label)
func run_tests():
    yield(get_tree().create_timer(0.2), "timeout")
    RunData.reset()
    RunData.set_player_count(1, true)
    TempStats.reset()
    LinkedStats.reset()
    RunData.add_character(ItemService.characters[0], 0)
    Utils.reset_stat_caches()
    for locale in ["en", "de"]:
        TranslationServer.set_locale(locale)
        for menu_source in [false, true]:
            var size = Vector2(400,780)
            var panel = load("res://ui/menus/shop/stats_container.tscn").instance()
            if menu_source:
                panel.free()
                var menu = load("res://ui/menus/ingame/ingame_main_menu.tscn").instance()
                panel = menu.find_node("StatsContainer", true, false)
                panel.get_parent().remove_child(panel)
                menu.free()
                panel.focus_neighbour_right = NodePath("")
            add_child(panel)
            panel.rect_size = size
            panel.update_player_stats(0)
            yield(get_tree(), "idle_frame")
            yield(get_tree(), "idle_frame")
            check(panel.get_combined_minimum_size().y <= 780, "panel fits original 780 height")
            var first_keys = []
            for stat in panel.primary_stats_groups[0]: first_keys.append(stat.key)
            check("STAT_LUCK" in first_keys, locale + " Luck on first page")
            check("STAT_HARVESTING" in first_keys, locale + " Harvesting on first page")
            print("STATS_LAYOUT ", locale, " ", size, " first=", first_keys, " minimum=",panel.get_combined_minimum_size())
            for tab in [0,1]:
                panel.update_tab(tab)
                var seen = []
                var groups = panel.msc_get_current_groups()
                for page in range(groups.size()):
                    panel._stats_carousel.set_page(page)
                    panel.msc_apply_current_page_visibility()
                    yield(get_tree(), "idle_frame")
                    yield(get_tree(), "idle_frame")
                    for stat in groups[page]:
                        check(stat.visible, "page row visible")
                        check(not stat in seen, "no duplicate stat across pages")
                        seen.append(stat)
                    var carousel = panel._stats_carousel
                    check(carousel.get_global_rect().end.y <= panel.get_global_rect().end.y + 1, "page arrows within panel")
                    if tab == 0:
                        check(panel.first_primary_stat == groups[page][0] and panel.last_primary_stat == groups[page][-1], "focus endpoints match visible page")
                        for stat in panel.primary_stats:
                            check(stat.visible or stat.focus_mode == Control.FOCUS_NONE, "hidden row not focusable")
                var expected = panel.primary_stats if tab == 0 else panel.secondary_stats
                check(seen.size() == expected.size(), "every real stat reachable, no padding")
            panel.queue_free()
            yield(get_tree(), "idle_frame")
    print("CC_RESULT ", to_json({"checks":checks,"failures":failures}))
    get_tree().quit(0 if failures.empty() else 1)

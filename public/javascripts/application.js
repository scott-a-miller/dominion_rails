function is_interactive(object) {
    return object.type == "selectable_image" ||
        object.type == "postable_image" ||
        object.type == "submit_button";
}

function submit_selection() {
    $(".submit_button_form").submit();
}

function show_next_event() {
    clear_last_event();
    if (events.length > 0) {
        var event = events.pop();
        last_event_ids = [];
        for (var i = 0; i < event.length; i++) {
            add_or_update_object(event[i]);
            last_event_ids[i] = event[i].dom_id
        }
        setTimeout("show_next_event()", update_millis);
    }
    else {
        if (should_update) {
            setTimeout('fetch_update();', update_millis);
        }
    }
}

function clear_last_event() {
    if (last_event_ids) {
        for (var i = 0; i < last_event_ids.length; i++) {
            $("#" + last_event_ids[i]).remove();
        }
    }
}

function handle_update(new_objects) {
    should_update = true;

    var new_object_ids = [];
    for (var i = 0; i < new_objects.length; i++) {
        add_or_update_object(new_objects[i]);
        if (is_interactive(new_objects[i])) {
            should_update = false;
        }
        new_object_ids[i] = new_objects[i].dom_id;
    };

    var old_object_ids = object_ids;
    for (var i = 0; i < old_object_ids.length; i++) {
        if ($.inArray(old_object_ids[i], new_object_ids) < 0) {
            $("#" + old_object_ids[i]).remove();
        }
    }

    add_card_focus();
    object_ids = new_object_ids;
    $("#updating_image").css("display", "none");

    show_next_event();
}

function fetch_update() {
    $("#updating_image").css("display", "inline");
    $.ajax({
            url: "/games/update",
                dataType : 'json',
                data : {},
                success : function(data, textStatus){
                  events = data[1];
                  handle_update(data[0]);
                },
                error : function(x, txt, e){
                  window.location.reload();
                }
            });
}

function add_card_focus() {
    $(".card, .selectable_card").mouseover(function() {
      var src = $(this).attr("src");
      var match = /(.*)\/[a-z]+\/(.*)-[a-z]+-gray.png/.exec(src);
      if (match) {
        $("#focused_card").attr("src", match[1] + "/medium/" + match[2] + "-medium-gray.png");
      }
      else {
        match = /(.*)\/[a-z]+\/(.*)-[a-z]+.png/.exec(src);
        if (match) {
          $("#focused_card").attr("src", match[1] + "/medium/" + match[2] + "-medium.png");
        }
      }
    });
}

function add_or_update_object(object) {
    if ($("#" + object.dom_id).length > 0) {
        update_object($("#" + object.dom_id).get(0), object);
    }
    else {
        add_object(object);
    }
}

function card_selected(clicked_link) {
    var selected_ids = selected_cards();
    var card_image = $(clicked_link).children("img").get(0);
    var selected_id = $(card_image).attr("card_id");
    if (selected_id) {
        var idx = $.inArray(selected_id, selected_ids);
        if (idx < 0) {
            selected_ids.push(selected_id);
            colorize_card(card_image, false);
            set_selected_cards(selected_ids);
        }
        else {
            selected_ids.splice(idx, 1);
            colorize_card(card_image, true);
            set_selected_cards(selected_ids);
        }
    }
    else {
        alert("No id in clicked image");
    }
}

function colorize_card(card_image, gray) {
    var src = $(card_image).attr("src");
    var match = /(.*)-gray.png/.exec(src);
    var root = null;
    if (match) {
        root = match[1];
    }
    else {
        match = /(.*).png/.exec(src);
        if (match) {
            root = match[1];
        }
    }
    if (root) {
        if (gray) {
            $(card_image).attr("src", root + "-gray.png");
        }
        else {
            $(card_image).attr("src", root + ".png");
        }
    }
}

function add_object(object) {
    if (object.type == "image") {
        $("body").append("<img border='0' " +
                         "id='" + object.dom_id + "' " +
                         (object.card_id >= 0 ? "class='card' " : "") +
                         "style='position:absolute; " +
                         (object.z ? "z-index:" + object.z + "; " : "") +
                         "top: " + object.y + "px; " +
                         "left: " + object.x + "px; " +
                         "' src='" + object.image_url + "'/>");
    }
    else if (object.type == "selectable_image") {
        var new_link = "<a href='#' onclick='card_selected(this); return false;' " +
                         "id='" + object.dom_id + "'>" +
                         "<img border='0' " +
                         (object.card_id >= 0 ? "class='card' " : "") +
                         (object.card_id >= 0 ? "card_id='" + object.card_id + "' " : "") +
                         "style='position:absolute; " +
                         (object.z ? "z-index:" + object.z + "; " : "") +
                         "top: " + object.y + "px; " +
                         "left: " + object.x + "px; " +
                         "' src='" + object.image_url + "'/>" +
            "</a>";
        $("body").append(new_link);
        colorize_card($("#" + object.dom_id).children().get(0), !object.enabled);
    }
    else if (object.type == "postable_image") {
        $("body").append("<a href='" + object.url + "' " +
                         "id='" + object.dom_id + "' " +
                         "/a>" +
                         "<img border='0' " +
                         (object.card_id ? "class='card' " : "") +
                         "style='position:absolute; " +
                         (object.z ? "z-index:" + object.z + "; " : "") +
                         "top: " + object.y + "px; " +
                         "left: " + object.x + "px; " +
                         "' src='" + object.image_url + "'/>" +
                         "</a>");
    }
    else if (object.type == "message") {
        var new_div = "<div " +
            "id='" + object.dom_id + "' " +
            "style='position:absolute; " +
            "font-weight: bold; " +
            "font-size: 12px; " +
            "font-family: arial; " +
            (object.z ? "z-index:" + object.z + "; " : "") +
            "top: " + object.y + "px; " +
            "left: " + object.x + "px'>" +
            object.text +
            "</div>"
        $("body").append(new_div);
    }
    else if (object.type == "panel") {
        var new_div = "<div " +
            "id='" + object.dom_id + "' " +
            "class='panel' " +
            "style='position:absolute; " +
            (object.z ? "z-index:" + object.z + "; " : "") +
            "width: " + object.width + "px; " +
            "height: " + object.height + "px; " +
            "top: " + object.y + "px; " +
            "left: " + object.x + "px'/>"
        $("body").append(new_div);
    }
    else if (object.type == "submit_button") {
        var new_form = "<form " +
            "id='" + object.dom_id + "' " +
            "class='submit_button_form' " +
            "action='" + object.url + "' " +
            "name='submit_ids_form' " +
            "style='position:absolute; " +
            "top: " + object.y + "px; " +
            (object.z ? "z-index:" + object.z + "; " : "") +
            "left: " + object.x + "px'>" +
            "<a href='#' onclick='submit_selection(); return false;'>" +
            "<img border='0' " +
            "src='" + object.image_url + "'/>" +
            "</a>" +
            "<input id='card_id_list' name='card_id_list' type='hidden' value='" + object.selected_ids + "'/>" +
            "</form>";
        $("body").append(new_form);
    }
}

function update_object(old_dom_object, object) {
    if (object.type == "image") {
        if ($(old_dom_object).attr("src") != object.image_url) {
            $(old_dom_object).attr("src", object.image_url);
        }
    }
    else if (object.type == "selectable_image") {
        old_img = $(old_dom_object).children("img").eq(0);
        if (object.card_id != old_img.attr("card_id")) {
            old_img.attr("card_id", object.card_id);
            if (object.card_id) {
                old_img.attr("class", "card");
            }
            else {
                old_img.attr("class", null);
            }
        }
        if (old_img.attr("src") != object.image_url) {
            old_img.attr("src", object.image_url);
        }
        colorize_card($("#" + object.dom_id).children().get(0), !object.enabled);
    }
    else if (object.type == "postable_image") {
        old_img = $(old_dom_object).children("img").eq(0);
        if (object.card_id != old_img.attr("card_id")) {
            old_img.attr("card_id", object.card_id);
            if (object.card_id) {
                old_img.attr("class", "card");
            }
            else {
                old_img.attr("class", null);
            }
        }
        if (old_img.attr("src") != object.image_url) {
            old_img.attr("src", object.image_url);
        }
    }
    else if (object.type == "message") {
        if ($(old_dom_object).text() != object.text) {
            $(old_dom_object).text(object.text);
        }
    }
    else if (object.type == "panel") {
        if ($(old_dom_object).css("height") != object.height) {
            $(old_dom_object).css("height", object.height);
        }
        if ($(old_dom_object).css("width") != object.width) {
            $(old_dom_object).css("width", object.width);
        }
    }
    else if (object.type == "submit_button") {
        $(old_dom_object).remove();
        var new_form = "<form " +
            "id='" + object.dom_id + "' " +
            "class='submit_button_form' " +
            "action='" + object.url + "' " +
            "name='submit_ids_form' " +
            "style='position:absolute; " +
            "top: " + object.y + "px; " +
            "left: " + object.x + "px'>" +
            "<a href='#' onclick='submit_selection(); return false;'>" +
            "<img border='0' " +
            "src='" + object.image_url + "'/>" +
            "</a>" +
            "<input id='card_id_list' name='card_id_list' type='hidden' value='" + object.selected_ids + "'/>" +
            "</form>";
        $("body").append(new_form);
    }
}


function selected_cards() {
    var card_list = $("#card_id_list").attr("value");
    if (card_list.length == 0) {
        return [];
    }
    else {
        return card_list.split(",");
    }
}

function set_selected_cards(selected_ids) {
    var card_list = "";
    if (selected_ids.length > 0) {
        card_list = selected_ids.join(",");
    }
    $("#card_id_list").attr("value", card_list);
}

function enter_pressed(e){
    var keycode;
    if (window.event) keycode = window.event.keyCode;
    else if (e) keycode = e.which;
    else return false;
    return (keycode == 13);
}

function send_message() {
    $.ajax({
            url: "/games/send_message",
                dataType : 'json',
                data : {message: $("#message_input").attr("value")},
                success : function(data, textStatus){
                  $("#message_input").attr("value", "");
                },
                error : function(x, txt, e){
                  alert(txt);
                }
            });
}
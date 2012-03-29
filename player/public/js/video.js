
var fullscreen = false;
$(function(){
    $('h1 .editable').editable('click', function(e){
        if( e.value.length < 1) return;
        var post_data = {title : e.value};
        $.post(app_root+'/v/'+video_id+'.json', post_data, function(e){
            if(e.error) alert(e.message);
            else{
            }
        }, 'json');

    });

    display_tags(tags);
    $('#tags .tags').editable({trigger : $('#tags .btn_edit'), action : 'click'}, function(e){
        var post_data = {};
        post_data.tags = e.value.split(/[\[\]]/).filter(function(tag){ return (tag.length > 0 && tag != '(empty)')});
        $.post(app_root+'/v/'+video_id+'.json', post_data, function(e){
            if(e.error) alert(e.message);
            else{
                tags = e.data.tags;
                display_tags(tags);
            }
        }, 'json');
    });

    $('#btn_fullscreen').click(function(){
        if(!fullscreen){
            $('video').css('width','100%').css('height','100%');
            $('#head').hide();
            fullscreen = true;
        }
        else{
            $('video').css('width','').css('height','');
            $('#head').show();
            fullscreen = false;
        }
    });

    $('#btn_delete').click(function(){
        if(!confirm('delete?')) return;
        $.del(app_root+'/v/'+video_id, {}, function(e){
            if(e.error) alert(e.message);
            else{
                alert(e.message);
                location.href = app_root;
            }
        }, 'json')
    });

    $('input#speed').change(function(e){
        var speed = e.target.value/10.0;
        $('input#speed_val').val(speed+'倍速');
        $('video')[0].playbackRate = speed;
    });
});

var display_tags = function(tags){
    $('#tags .tags').html('');
    if(tags.length < 1){
        $('#tags .tags').text('(empty)');
    }
    else{
        tags.map(function(tag){
            $('<a>').html('['+tag.escape_html()+']').attr('href',app_root+'/tag/'+tag).addClass('tag').appendTo('#tags .tags');
        });
    }
};
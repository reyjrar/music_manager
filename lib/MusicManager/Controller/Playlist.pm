package MusicManager::Controller::Playlist;
use Mojo::Base 'Mojolicious::Controller';
use File::Spec;
use Try::Tiny;


sub switch {
    my $self = shift;

    my $playlist = $self->req->param('playlist_name');
    my $list_info = $self->app->playlists->get( $playlist );

    if( defined $list_info ) {
        my $err = undef;
        my $mpd = $self->app->mpd;
        try {
            $mpd->stop;
            $mpd->playlist->clear;
            $mpd->playlist->load( $list_info->{name} );
            $mpd->play;
        } catch {
            $err=shift;
        };
        $err ?    $self->flash(error => "Error loading playlist($playlist): $err")
                : $self->flash(message => "Loaded the $playlist playlist");
    }
    else {
        $self->flash(error => "Unknown playlist specified: $playlist");
    }
    $self->redirect_to( '/' );
}

sub add_song {
    my $self = shift;

    # Grab Song File
    my $relative_path = $self->req->param('song_file');
    my $song_file = File::Spec->catfile(
        $self->config->{mpd}{media_dir},
        $relative_path
    );
    my $playlist = $self->req->param('playlist_name');

    if( -f $song_file ) {
        my $err=undef;
        try {
            $self->app->playlists->add_song_to(
                $playlist,
                $song_file,
            );
        } catch {
            ($err) = shift;
        };
        if( $err ) {
            $self->flash( error => "Failed adding song to playlist: $err" );
        }
        else {
            my $title = $self->req->param('track_title');
            my $artist = $self->req->param('track_artist');
            $self->flash( message => qq{Added "$title" by $artist to $playlist playlist} );
        }
    }
    else {
        $self->flash( error => "Bad song file: $song_file" );
    }

    $self->redirect_to( '/' );
}

1;

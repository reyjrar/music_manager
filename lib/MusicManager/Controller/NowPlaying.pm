package MusicManager::Controller::NowPlaying;
use Mojo::Base 'Mojolicious::Controller';
use MIME::Base64;
use Try::Tiny;

# Controller to modify the currently playing song list
sub save {
    my $self = shift;
    my $mpd = $self->app->mpd;

    my $playlist_name = $self->req->param( 'saveas' );
    # Scrub playlist name
    $playlist_name =~ s/\s+/\_/g;
    $playlist_name =~ s/[^0-9a-z-A-Z\_\-]+//g;

    # MPD can't save a playlist with the same name
    # so we remove it first!
    try {
        $mpd->playlist->rm($playlist_name);
        $self->app->log->info("Successfully deleted playlist $playlist_name");
    };
    $mpd->playlist->save( $playlist_name );

    $self->flash( message => "Playlist saved as '$playlist_name'" );
    $self->redirect_to('/');

}

sub add_artist {
    my $self = shift;
    my $mpd = $self->app->mpd;

    my $artist = $self->stash( 'artist' );
    my @songs = $self->app->files->songs_from_path( $artist );
    my $songs = scalar @songs;

    if( $songs > 0 ) {
        try {
            $mpd->playlist->add( @songs );
        };
        $self->flash(message => "Added $songs songs by $artist");
    }
    else {
        $self->flash(error => "No songs found for artist: $artist");
    }

    $self->redirect_to('/');
}

sub replace_artist {
    my $self = shift;
    my $mpd = $self->app->mpd;

    my $artist = $self->stash( 'artist' );
    my @songs = $self->app->files->songs_from_path( $artist );
    my $songs = scalar @songs;

    if( $songs > 0 ) {
        $mpd->stop;
        $mpd->playlist->clear();
        try {
            $mpd->playlist->add( @songs );
        };
        $mpd->play;
        $self->flash(message => "Added $songs songs by $artist, replacing playlist");
    }
    else {
        $self->flash(error => "No songs found for artist: $artist");
    }

    $self->redirect_to('/');
}

sub add_artist_album {
    my $self = shift;
    my $mpd = $self->app->mpd;

    my $artist = $self->stash( 'artist' );
    my $album = $self->stash( 'album' );
    my @songs = $self->app->files->songs_from_path( $artist, $album );
    my $songs = scalar @songs;

    if( $songs > 0 ) {
        try {
            $mpd->playlist->add( @songs );
        };
        $self->flash(message => "Added $songs songs by $artist from $album");
    }
    else {
        $self->flash(error => "No songs found for album: $artist - $album");
    }

    $self->redirect_to('/');
}

sub replace_artist_album {
    my $self = shift;
    my $mpd = $self->app->mpd;

    my $artist = $self->stash( 'artist' );
    my $album = $self->stash( 'album' );
    my @songs = $self->app->files->songs_from_path( $artist, $album );
    my $songs = scalar @songs;

    if( $songs > 0 ) {
        $mpd->stop;
        $mpd->playlist->clear();
        try {
            $mpd->playlist->add( @songs );
        };
        $mpd->play;
        $self->flash(message => "Added $songs songs by $artist from $album");
    }
    else {
        $self->flash(error => "No songs found for album: $artist - $album");
    }

    $self->redirect_to('/');
}

sub add_song {
    my $self = shift;
    my $mpd = $self->app->mpd;

    my $file = decode_base64( $self->stash('song_id') );

    try {
        die "unknown file" unless $file;
        $mpd->playlist->add( $file );
        $self->flash(message => "Added Song ID: $file");
    } catch {
        my $err = shift;
        $self->flash(error => "Received error adding $file: $err");
    };

    $self->redirect_to( '/' );
}

sub del_song {
    my $self = shift;
    my $id = $self->stash('song_id');

    try {
        $self->app->mpd->playlist->deleteid( $id );
        $self->flash(message => "Removed Song ID: $id from playlist");
    } catch {
        my $err = shift;
        $self->flash(error => "Received error removing songid:$id from playlist");
    };

    $self->redirect_to( '/' );
}

1;

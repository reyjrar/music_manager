package MusicManager::Controller::NowPlaying;
use Mojo::Base 'Mojolicious::Controller';
use Try::Tiny;

# Controller to modify the currently playing song list

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


1;

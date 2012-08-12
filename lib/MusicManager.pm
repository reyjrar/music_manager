package MusicManager;
use Mojo::Base 'Mojolicious';
use Audio::MPD;
use MusicManager::Model::Playlists;
use MusicManager::Model::Files;

# Music Player Daemon
has 'mpd' => sub {
    my $self = shift;
    return Audio::MPD->new( { host => $self->config->{mpd}{host} } );
};

# Playlist Handling
has 'playlists' => sub {
    my $self = shift;
    return MusicManager::Model::Playlists->new( playlist_dir => $self->config->{mpd}{playlist_dir} );
};

# Playlist Handling
has 'files' => sub {
    my $self = shift;
    return MusicManager::Model::Files->new( media_dir => $self->config->{mpd}{media_dir} );
};


# This method will run once at server start
sub startup {
    my $self = shift;

    # Session Setup
    $self->secret('my mpd secret is sooo cool!');
    $self->sessions->default_expiration(3600*24*7);

    # Configuration
    my $config = $self->plugin( yaml_config => {
            file => 'music_manager.yaml',
            stash_key   => 'config',
    });

    # Hook to refresh state
    $self->hook( before_dispatch => sub {
              my $c = shift;
              my %curr = map { $_ => '' } qw(id file title artist album);
              if( my $t = $c->app->mpd->current ) {
                  %curr = (
                        id => $t->id,
                        title => $t->title,
                        artist => $t->artist,
                        album => $t->album,
                        file => $t->file,
                    );
              }
              $c->stash( current_track => \%curr );
              $c->stash( mpd_status => $c->app->mpd->status );
          }
    );

    # Routing via Controller::*
    my $r = $self->routes;
    $r->namespace('MusicManager::Controller');

    # Normal route to controller
    $r->route('/')->to('main#index');

    # AJAX Routes
    $r->route('/ajax/current_track')->to( controller => 'AJAX', action => 'current_track');

    # Library Routes
    $r->route('/library')->to('library#artists');
    $r->route('/library/artists')->to('library#artists');
    $r->route('/library/artist/:artist')->to('library#artist');
    $r->route('/library/album/:album')->to('library#album');

    # Now Playing
    $r->route('/nowplaying/add/artist/:artist')->to(controller => 'NowPlaying', action => 'add_artist');
    $r->route('/nowplaying/replace/artist/:artist')->to(controller => 'NowPlaying', action => 'replace_artist');
    $r->route('/nowplaying/add/album/:artist/:album')->to(controller => 'NowPlaying', action => 'add_artist_album');
    $r->route('/nowplaying/replace/album/:artist/:album')->to(controller => 'NowPlaying', action => 'replace_artist_album');
    $r->route('/nowplaying/del/song/:song_id')->to(controller => 'NowPlaying', action => 'del_song');
    $r->route('/nowplaying/save')->to(controller => 'NowPlaying', action => 'save');

    # Playlist routes
    $r->route('/playlist/add_song')->to('playlist#add_song');
    $r->route('/playlist/switch')->to('playlist#switch');

    # MPD Control Routes
    $r->route('/mpd/do/:command')->to('MPD#do');
    $r->route('/mpd/toggle/:setting')->to('MPD#toggle');
    $r->route('/mpd/volume/:adjustment')->to('MPD#volume');
    $r->route('/mpd/playid/:song_id')->to('MPD#playid');
}

1;

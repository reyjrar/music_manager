package MusicManager;
use Mojo::Base 'Mojolicious';
use Audio::MPD;
use MusicManager::Model::Playlists;

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
              $c->stash( current_track => $c->app->mpd->current );
              $c->stash( mpd_status => $c->app->mpd->status );
          }
    );

    # Routing via Controller::*
    my $r = $self->routes;
    $r->namespace('MusicManager::Controller');

    # Normal route to controller
    $r->route('/')->to('main#index');
    $r->route('/playlist/add_song')->to('playlist#add_song');
    $r->route('/playlist/switch')->to('playlist#switch');

    $r->route('/mpd/do/:command')->to('MPD#do');
    $r->route('/mpd/volume/:adjustment')->to('MPD#volume');
}

1;

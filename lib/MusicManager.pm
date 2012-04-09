package MusicManager;
use Mojo::Base 'Mojolicious';
use Audio::MPD;

has 'mpd' => sub { my $self = shift; return Audio::MPD->new( { host => $self->config->{mpd}{host} } ); };

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

    # Hook to refresh current_track
    $self->hook( before_dispatch => sub {
              my $c = shift;
              $c->stash( current_track => $c->app->mpd->current )
          }
    );

    # Routing via Controller::*
    my $r = $self->routes;
    $r->namespace('MusicManager::Controller');

    # Normal route to controller
    $r->route('/')->to('main#index');
}

1;

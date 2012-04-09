package MusicManager;
use Mojo::Base 'Mojolicious';
use Audio::MPD;

has 'mpd' => sub { Audio::MPD->new( { host => '10.0.1.10' } ); };

# This method will run once at server start
sub startup {
    my $self = shift;

    # Session Setup
    $self->secret('my mpd secret is sooo cool!');
    $self->sessions->default_expiration(3600*24*7);

    # Hook to refresh current_track
    $self->hook( before_dispatch => sub {
              $self->defaults( current_track => $self->mpd->current )
          }
    );

    # Router
    my $r = $self->routes;
    $r->namespace('MusicManager::Controller');

    # Normal route to controller
    $r->route('/')->to('main#index');
}

1;

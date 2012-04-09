package MusicManager;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->route('/')->to('main#index');
}

1;

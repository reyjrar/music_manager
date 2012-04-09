package MusicManager::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;

  my @playlists = $self->app->playlists->names();

  $self->stash( playlists => \@playlists );

  $self->render();
}

1;

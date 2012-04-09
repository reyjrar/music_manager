package MusicManager::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;

  $self->stash( current_track => $self->app->mpd->current );
  $self->render();
}

1;

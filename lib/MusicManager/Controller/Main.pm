package MusicManager::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;

  # Stash Playlists
  my @playlists = $self->app->playlists->names();
  $self->stash( playlists => \@playlists );

  # Stash Library Details
  my @songs = $self->app->mpd->playlist->as_items;
  $self->stash( songs => \@songs );

  $self->render();
}

1;

package MusicManager::Controller::Search;
use Mojo::Base 'Mojolicious::Controller';

sub songs {
    my $self = shift;
    $self->render();
}

1;

package MusicManager::Controller::Search;
use Mojo::Base 'Mojolicious::Controller';

sub songs {
    my $self = shift;
    my $qs = $self->param('qs');

    $self->render();
}

1;

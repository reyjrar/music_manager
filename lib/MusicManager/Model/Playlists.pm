package MusicManager::Model::Playlists;
use Mojo::Base -base;
use File::Spec;
use File::Basename;
use File::Find::Rule;

has 'playlist_dir';
has 'lists' => sub { my $self = shift; return $self->_get_lists };

my %_valid_song_ext = map { $_ => 1 } qw(mp3 ogg aac);

sub get {
    my ($self,$name) = @_;
    my %list = %{ $self->lists };

    return unless exists $list{$name};

    my %i = ( name => $name, file => $list{$name} );
    return wantarray ? %i : \%i;
}

sub names {
    my $self = shift;
    my @names = sort keys %{ $self->lists };
    return wantarray ? @names : \@names;
}

sub add_song_to {
    my ($self,$list_name,$song_file) = @_;
    my $list = $self->get( $list_name );
    my ($ext) = ($song_file =~ /\.([^.]+)$/);

    # Fatally Die on some bad things
    die "invalid file extension($ext) for $song_file\n"
        unless exists $_valid_song_ext{$ext};
    die "cannot add song to unknown list: $list_name\n" unless defined $list;
    die "invalid song_file: $song_file\n" unless -f $song_file;

    open my $fh, '+<', $list->{file} or die "unable to open $list->{file}: $!\n";
    my $found = 0;
    while(my $line = <$fh>) {
        chomp $line;
        $found = 1 if $line eq $song_file;
        last if $found;
    }
    if( !$found ) {
        print $fh "$song_file\n";
    }
}

sub _get_lists {
    my $self = shift;

    my @files = File::Find::Rule->file()->name('*.m3u')->in( $self->playlist_dir );

    my %lists = map {
        my $b = basename $_;
        $b =~ s/\.m3u//;
        $b => $_;
    } @files;

    return \%lists;
}

1;

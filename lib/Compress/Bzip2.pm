# File	  : Bzip2.pm
# Author  : Rob Janes
# Created : 14 January 2005
# Version : 2.00
#
#     Copyright (c) 2005 Rob Janes. All rights reserved.
#     This program is free software; you can redistribute it and/or
#     modify it under the same terms as Perl itself.
#

package Compress::Bzip2;

use 5.006;

use strict;
use warnings;

use Carp;

require Exporter;
use AutoLoader;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Compress::Bzip2 ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS =
    ( 'constants' => [ qw(
			  BZ_CONFIG_ERROR
			  BZ_DATA_ERROR
			  BZ_DATA_ERROR_MAGIC
			  BZ_FINISH
			  BZ_FINISH_OK
			  BZ_FLUSH
			  BZ_FLUSH_OK
			  BZ_IO_ERROR
			  BZ_MAX_UNUSED
			  BZ_MEM_ERROR
			  BZ_OK
			  BZ_OUTBUFF_FULL
			  BZ_PARAM_ERROR
			  BZ_RUN
			  BZ_RUN_OK
			  BZ_SEQUENCE_ERROR
			  BZ_STREAM_END
			  BZ_UNEXPECTED_EOF
			 ) ],

      'utilities' => [ qw(
			  &bzopen
			  &bzinflateInit
			  &bzdeflateInit
			  &memBzip &memBunzip
			  &bzip2 &bunzip2
			  &bzlibversion
			  $bzerrno
			  ) ],

      'bzip1' => [ qw(
		      &compress
		      &decompress
		      ) ],

      'gzip' => [ qw(
		     &gzopen
		     &gzinflateInit
		     &gzdeflateInit
		     &memGzip &memGunzip
		     $gzerrno
		     ) ],
      );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'utilities'} },
		   @{ $EXPORT_TAGS{'constants'} },
		   @{ $EXPORT_TAGS{'bzip1'} },
		   @{ $EXPORT_TAGS{'gzip'} },
		   );

$EXPORT_TAGS{'all'} = [ @EXPORT_OK ];

our @EXPORT = ( @{ $EXPORT_TAGS{'utilities'} }, @{ $EXPORT_TAGS{'constants'} } );

our $VERSION = "2.00";

our $bzerrno = "";
our $gzerrno;
*gzerrno = \$bzerrno;


sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&Compress::Bzip2::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
#XXX	if ($] >= 5.00561) {
#XXX	    *$AUTOLOAD = sub () { $val };
#XXX	}
#XXX	else {
	    *$AUTOLOAD = sub { $val };
#XXX	}
    }
    goto &$AUTOLOAD;
}

require XSLoader;
XSLoader::load('Compress::Bzip2', $VERSION);

#bootstrap Compress::Bzip2 $VERSION;

# Preloaded methods go here.

sub gzopen($$) {
  goto &bzopen;
}

sub gzread ( $$;$ ) {
  goto &bzread;
}

sub gzreadline ( $$ ) {
  goto &bzreadline;
}

sub gzwrite ( $$ ) {
  goto &bzwrite;
}

sub gzflush ( $ ) {
  goto &bzflush;
}

sub gzclose ( $ ) {
  goto &bzclose;
}

sub gzeof ( $ ) {
  goto &bzeof;
}

sub gzsetparams ( $$ ) {
  return 0;
}

sub gzerror ( $ ) {
  goto &bzerror;
}

sub deflateParams ( $;@ ) {
  return 0;
}

sub flush ( $;$ ) {
  goto &bzflush;
}

sub dict_adler ( $ ) {
  return;
}

sub msg ( $ ) {
  return;
}

sub inflateSync ( $ ) {
  return 0;
}

sub memGzip ( $ ) {
  goto &memBzip;
}

sub memGunzip ( $ ) {
  goto &memBunzip;
}

sub adler32 ( $;$ ) {
  return 0;
}

sub crc32 ( $;$ ) {
  return 0;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;

__END__


=pod

=head1 NAME

Compress::Bzip2 - Interface to Bzip2 compression library

=head1 SYNOPSIS

    use Compress::Bzip2 qw(:all :constant :utilities :gzip);

    ($bz, $status) = bzdeflateInit( [PARAMS] ) ;
    ($out, $status) = $bz->bzdeflate($buffer) ;

    ($bz, $status) = bzinflateInit( [PARAMS] ) ;
    ($out, $status) = $bz->bzinflate($buffer) ;

    ($out, $status) = $bz->bzflush() ;
    ($out, $status) = $bz->bzclose() ;

    $dest = memBzip($source);
        alias compress
    $dest = memBunzip($source);
        alias uncompress

    $bz = Compress::Bzip2->new( [PARAMS] );

    $bz = bzopen($filename or filehandle, $mode);
        alternate, with $bz created by new():
    $bz->bzopen($filename or filehandle, $mode);

    $bytesread = $bz->bzread($buffer [,$size]) ;
    $bytesread = $bz->bzreadline($line);
    $byteswritten = $bz->bzwrite($buffer);
    $errstring = $bz->bzerror(); 
    $status = $bz->bzeof();
    $status = $bz->bzflush();
    $status = $bz->bzclose() ;

    $status = $bz->bzsetparams( $param => $setting );

    $bz->total_in() ;
    $bz->total_out() ;

    $verstring = $bz->bzversion();

    $Compress::Bzip2::bzerrno

=head1 DESCRIPTION

The I<Compress::Bzip2> module provides a Perl interface to the I<Bzip2>
compression library (see L</AUTHOR> for details about where to get
I<Bzip2>). A relevant subset of the functionality provided by I<Bzip2>
is available in I<Compress::Bzip2>.

All string parameters can either be a scalar or a scalar reference.

The module can be split into two general areas of functionality, namely
in-memory compression/decompression and read/write access to I<bzip2>
files. Each of these areas will be discussed separately below.

=head1 DEFLATE 

The Perl interface will I<always> consume the complete input buffer
before returning. Also the output buffer returned will be
automatically grown to fit the amount of output available.

Here is a definition of the interface available:

=head2 B<($d, $status) = bzdeflateInit( [OPT] )>

Initialises a deflation stream. 

If successful, it will return the initialised deflation stream, B<$d>
and B<$status> of C<BZ_OK> in a list context. In scalar context it
returns the deflation stream, B<$d>, only.

If not successful, the returned deflation stream (B<$d>) will be
I<undef> and B<$status> will hold the exact I<bzip2> error code.

The function optionally takes a number of named options specified as
C<-Name=E<gt>value> pairs. This allows individual options to be
tailored without having to specify them all in the parameter list.

Here is a list of the valid options:

=over 5

=item B<-verbosity>

Defines the verbosity level. Valid values are 0 through 4,

The default is C<-verbosity =E<gt> 0>.

=item B<-blockSize100k>

Defines the buffering factor of compression method.  The algorithm
buffers all data until the buffer is full, then it flushes all the
data out.  Use -blockSize100k to specify the size of the buffer.

Valid settings are 1 through 9, representing a blocking in multiples
of 100k.

Note that each such block has an overhead of leading and trailing
synchronization bytes.  bzip2 recovery uses this information to
pull useable data out of a corrupted file.

A streaming application would probably want to set the blocking low.

=item B<-workFactor>

The workFactor setting tells the deflation algorithm how much work
to invest to compensate for repetitive data.

workFactor may be a number from 0 to 250 inclusive.  The default setting
is 30.

See the bzip documentation for more information.

=back

Here is an example of using the B<deflateInit> optional parameter list
to override the default buffer size and compression level. All other
options will take their default values.

    bzdeflateInit( -blockSize100k => 1, -verbosity => 1 );


=head2 B<($out, $status) = $d-E<gt>bzdeflate($buffer)>


Deflates the contents of B<$buffer>. The buffer can either be a scalar
or a scalar reference.  When finished, B<$buffer> will be
completely processed (assuming there were no errors). If the deflation
was successful it returns deflated output, B<$out>, and a status
value, B<$status>, of C<Z_OK>.

On error, B<$out> will be I<undef> and B<$status> will contain the
I<zlib> error code.

In a scalar context B<bzdeflate> will return B<$out> only.

As with the internal buffering of the I<deflate> function in I<bzip2>,
it is not necessarily the case that any output will be produced by
this method. So don't rely on the fact that B<$out> is empty for an
error test.  In fact, given the size of bzdeflates internal buffer,
with most files it's likely you won't see any output at all until
flush or close.


=head2 B<($out, $status) = $d-E<gt>bzflush([flush_type])>

Typically used to finish the deflation. Any pending output will be
returned via B<$out>.  B<$status> will have a value C<BZ_OK> if
successful.

In a scalar context B<bzflush> will return B<$out> only.

Note that flushing can seriously degrade the compression ratio, so it
should only be used to terminate a decompression (using C<BZ_FLUSH>) or
when you want to create a I<full flush point> (using C<BZ_FINISH>).

The allowable values for C<flush_type> are C<BZ_FLUSH> and C<BZ_FINISH>.

For a handle opened for "w" (bzwrite), the default is C<BZ_FLUSH>.
For a stream, the default for C<flush_type> is C<BZ_FINISH> (which is
essentially a close and reopen).

It is strongly recommended that you only set the C<flush_type>
parameter if you fully understand the implications of what it
does. See the C<bzip2> documentation for details.

=head2 Example

Here is a trivial example of using B<bzdeflate>. It simply reads standard
input, deflates it and writes it to standard output.

    use strict ;
    use warnings ;

    use Compress::Bzip2 ;

    binmode STDIN;
    binmode STDOUT;
    my $x = bzdeflateInit()
       or die "Cannot create a deflation stream\n" ;

    my ($output, $status) ;
    while (<>)
    {
        ($output, $status) = $x->bzdeflate($_) ;
    
        $status == BZ_OK
            or die "deflation failed\n" ;
    
        print $output ;
    }
    
    ($output, $status) = $x->bzclose() ;
    
    $status == BZ_OK
        or die "deflation failed\n" ;
    
    print $output ;

=head1 INFLATE

Here is a definition of the interface:


=head2 B<($i, $status) = inflateInit()>

Initialises an inflation stream. 

In a list context it returns the inflation stream, B<$i>, and the
I<zlib> status code (B<$status>). In a scalar context it returns the
inflation stream only.

If successful, B<$i> will hold the inflation stream and B<$status> will
be C<BZ_OK>.

If not successful, B<$i> will be I<undef> and B<$status> will hold the
I<bzlib.h> error code.

The function optionally takes a number of named options specified as
C<-Name=E<gt>value> pairs. This allows individual options to be
tailored without having to specify them all in the parameter list.
 
For backward compatibility, it is also possible to pass the parameters
as a reference to a hash containing the name=>value pairs.
 
The function takes one optional parameter, a reference to a hash.  The
contents of the hash allow the deflation interface to be tailored.
 
Here is a list of the valid options:

=over 5

=item B<-small>

B<small> may be 0 or 1.  Set C<small> to one to use a slower, less
memory intensive algorithm.

=item B<-verbosity>

Defines the verbosity level. Valid values are 0 through 4,

The default is C<-verbosity =E<gt> 0>.

=back

Here is an example of using the B<bzinflateInit> optional parameter.

    bzinflateInit( -small => 1, -verbosity => 1 );

=head2 B<($out, $status) = $i-E<gt>bzinflate($buffer)>

Inflates the complete contents of B<$buffer>. The buffer can either be
a scalar or a scalar reference.

Returns C<BZ_OK> if successful and C<BZ_STREAM_END> if the end of the
compressed data has been successfully reached.  If not successful,
B<$out> will be I<undef> and B<$status> will hold the I<bzlib> error
code.

The C<$buffer> parameter is modified by C<bzinflate>. On completion it
will contain what remains of the input buffer after inflation. This
means that C<$buffer> will be an empty string when the return status
is C<BZ_OK>. When the return status is C<BZ_STREAM_END> the C<$buffer>
parameter will contains what (if anything) was stored in the input
buffer after the deflated data stream.

This feature is useful when processing a file format that encapsulates
a compressed data stream.

=head2 Example

Here is an example of using B<bzinflate>.

    use strict ;
    use warnings ;
    
    use Compress::Bzip2;
    
    my $x = bzinflateInit()
       or die "Cannot create a inflation stream\n" ;
    
    my $input = '' ;
    binmode STDIN;
    binmode STDOUT;
    
    my ($output, $status) ;
    while (read(STDIN, $input, 4096))
    {
        ($output, $status) = $x->bzinflate(\$input) ;
    
        print $output 
            if $status == BZ_OK or $status == BZ_STREAM_END ;
    
        last if $status != BZ_OK ;
    }
    
    die "inflation failed\n"
        unless $status == BZ_STREAM_END ;

=head1 COMPRESS/UNCOMPRESS

Two high-level functions are provided by I<bzlib> to perform in-memory
compression. They are B<memBzip> and B<memBunzip>. Two Perl subs are
provided which provide similar functionality.

=over 5

=item B<$dest = memBzip($source);>

Compresses B<$source>. If successful it returns the
compressed data. Otherwise it returns I<undef>.

The source buffer can either be a scalar or a scalar reference.

=item B<$dest = memBunzip($source);>

Uncompresses B<$source>. If successful it returns the uncompressed
data. Otherwise it returns I<undef>.

The source buffer can either be a scalar or a scalar reference.

=back

=head1 BZIP INTERFACE

A number of functions are supplied in I<bzlib> for reading and writing
I<gzip> files. Unfortunately, most of them are not suitable.  So, this
module provides another interface, over top of the low level bzlib
methods.

=over 5

=item B<$bz = bzopen(filename or filehandle, mode)>

This function returns an object which is used to access the other
I<bzip2> methods.

The B<mode> parameter is used to specify both whether the file is
opened for reading or writing, with "r" or "w" respectively.

If a reference to an open filehandle is passed in place of the
filename, it better be positioned to the start of a compression
sequence.

=item B<$bytesread = $bz-E<gt>bzread($buffer [, $size]) ;>

Reads B<$size> bytes from the compressed file into B<$buffer>. If
B<$size> is not specified, it will default to 4096. If the scalar
B<$buffer> is not large enough, it will be extended automatically.

Returns the number of bytes actually read. On EOF it returns 0 and in
the case of an error, -1.

=item B<$bytesread = $bz-E<gt>bzreadline($line) ;>

Reads the next line from the compressed file into B<$line>. 

Returns the number of bytes actually read. On EOF it returns 0 and in
the case of an error, -1.

It IS legal to intermix calls to B<bzread> and B<bzreadline>.

At this time B<bzreadline> ignores the variable C<$/>
(C<$INPUT_RECORD_SEPARATOR> or C<$RS> when C<English> is in use). The
end of a line is denoted by the C character C<'\n'>.

=item B<$byteswritten = $bz-E<gt>bzwrite($buffer) ;>

Writes the contents of B<$buffer> to the compressed file. Returns the
number of bytes actually written, or 0 on error.

=item B<$status = $bz-E<gt>bzflush($flush) ;>

Flushes all pending output to the compressed file.
Works identically to the I<zlib> function it interfaces to. Note that
the use of B<bzflush> can degrade compression.

Returns C<BZ_OK> if B<$flush> is C<BZ_FINISH> and all output could be
flushed. Otherwise the bzlib error code is returned.

Refer to the I<bzlib> documentation for the valid values of B<$flush>.

=item B<$status = $bz-E<gt>bzeof() ;>

Returns 1 if the end of file has been detected while reading the input
file, otherwise returns 0.

=item B<$bz-E<gt>bzclose>

Closes the compressed file. Any pending data is flushed to the file
before it is closed.

=item B<$bz-E<gt>bzsetparams( [OPTS] );>

Change settings for the deflate stream C<$bz>.

The list of the valid options is shown below. Options not specified
will remain unchanged.

=over 5

=item B<-verbosity>

Defines the verbosity level. Valid values are 0 through 4,

The default is C<-verbosity =E<gt> 0>.

=item B<-blockSize100k>

For bzip object opened for stream deflation or write.

Defines the buffering factor of compression method.  The algorithm
buffers all data until the buffer is full, then it flushes all the
data out.  Use -blockSize100k to specify the size of the buffer.

Valid settings are 1 through 9, representing a blocking in multiples
of 100k.

Note that each such block has an overhead of leading and trailing
synchronization bytes.  bzip2 recovery uses this information to
pull useable data out of a corrupted file.

A streaming application would probably want to set the blocking low.

=item B<-workFactor>

For bzip object opened for stream deflation or write.

The workFactor setting tells the deflation algorithm how much work
to invest to compensate for repetitive data.

workFactor may be a number from 0 to 250 inclusive.  The default setting
is 30.

See the bzip documentation for more information.

=item B<-small>

For bzip object opened for stream inflation or read.

B<small> may be 0 or 1.  Set C<small> to one to use a slower, less
memory intensive algorithm.

=back

=item B<$bz-E<gt>bzerror>

Returns the I<bzlib> error message or number for the last operation
associated with B<$bz>. The return value will be the I<bzlib> error
number when used in a numeric context and the I<bzlib> error message
when used in a string context. The I<bzlib> error number constants,
shown below, are available for use.

  BZ_CONFIG_ERROR
  BZ_DATA_ERROR
  BZ_DATA_ERROR_MAGIC
  BZ_FINISH
  BZ_FINISH_OK
  BZ_FLUSH
  BZ_FLUSH_OK
  BZ_IO_ERROR
  BZ_MAX_UNUSED
  BZ_MEM_ERROR
  BZ_OK
  BZ_OUTBUFF_FULL
  BZ_PARAM_ERROR
  BZ_RUN
  BZ_RUN_OK
  BZ_SEQUENCE_ERROR
  BZ_STREAM_END
  BZ_UNEXPECTED_EOF

=item B<$bzerrno>

The B<$bzerrno> scalar holds the error code associated with the most
recent I<gzip> routine. Note that unlike B<bzerror()>, the error is
I<not> associated with a particular file.

As with B<bzerror()> it returns an error number in numeric context and
an error message in string context. Unlike B<bzerror()> though, the
error message will correspond to the I<bzlib> message when the error is
associated with I<bzlib> itself, or the UNIX error message when it is
not (i.e. I<bzlib> returned C<Z_ERRORNO>).

As there is an overlap between the error numbers used by I<bzlib> and
UNIX, B<$bzerrno> should only be used to check for the presence of
I<an> error in numeric context. Use B<bzerror()> to check for specific
I<bzlib> errors. The I<gzcat> example below shows how the variable can
be used safely.

=back


=head2 Examples

Here is an example script which uses the interface. It implements a
I<bzcat> function.

    use strict ;
    use warnings ;
    
    use Compress::Bzip2 ;
    
    die "Usage: bzcat file...\n"
        unless @ARGV ;
    
    my $file ;
    
    foreach $file (@ARGV) {
        my $buffer ;
    
        my $bz = bzopen($file, "rb") 
             or die "Cannot open $file: $bzerrno\n" ;
    
        print $buffer while $bz->bzread($buffer) > 0 ;
    
        die "Error reading from $file: $bzerrno" . ($bzerrno+0) . "\n" 
            if $bzerrno != BZ_STREAM_END ;
        
        $gz->bzclose() ;
    }

Below is a script which makes use of B<bzreadline>. It implements a
very simple I<grep> like script.

    use strict ;
    use warnings ;
    
    use Compress::Bzip2 ;
    
    die "Usage: bzgrep pattern file...\n"
        unless @ARGV >= 2;
    
    my $pattern = shift ;
    
    my $file ;
    
    foreach $file (@ARGV) {
        my $bz = bzopen($file, "rb") 
             or die "Cannot open $file: $bzerrno\n" ;
    
        while ($bz->bzreadline($_) > 0) {
            print if /$pattern/ ;
        }
    
        die "Error reading from $file: $bzerrno\n" 
            if $bzerrno != Z_STREAM_END ;
        
        $bz->bzclose() ;
    }

This script, I<bzstream>, does the opposite of the I<bzcat> script
above. It reads from standard input and writes a bzip file to standard
output.

    use strict ;
    use warnings ;
    
    use Compress::Bzip2 ;
    
    binmode STDOUT;	# bzopen only sets it on the fd
    
    my $bz = bzopen(\*STDOUT, "wb")
    	  or die "Cannot open stdout: $bzerrno\n" ;
    
    while (<>) {
        $bz->bzwrite($_) 
    	or die "error writing: $bzerrno\n" ;
    }

    $bz->bzclose ;

=head2 memBzip

This function is used to create an in-memory bzip file. 
It creates a minimal bzip header.

    $dest = memBzip($buffer) ;

If successful, it returns the in-memory bzip file, otherwise it returns
undef.

The buffer parameter can either be a scalar or a scalar reference.

=head2 memBunzip

This function is used to uncompress an in-memory bzip file.

    $dest = memBunzip($buffer) ;

If successful, it returns the uncompressed bzip file, otherwise it
returns undef.

The buffer parameter can either be a scalar or a scalar reference. The
contents of the buffer parameter are destroyed after calling this
function.

=head1 EXPORT

Use the tags :all, :utilities, :constants, and :gzip.

=head2 Export tag :utilities

This gives an interface to the bzip2 methods.

    bzopen
    bzinflateInit
    bzdeflateInit
    memBzip
    memBunzip
    bzip2
    bunzip2
    bzlibversion
    $bzerrno

=head2 Export tag :gzip

This gives compatibility with Compress::Zlib.

    gzopen
    gzinflateInit
    gzdeflateInit
    memGzip
    memGunzip
    $gzerrno

=head1 Exportable constants

All the I<bzlib> constants are automatically imported when you make use
of I<Compress::Bzip2>.

  BZ_CONFIG_ERROR
  BZ_DATA_ERROR
  BZ_DATA_ERROR_MAGIC
  BZ_FINISH
  BZ_FINISH_OK
  BZ_FLUSH
  BZ_FLUSH_OK
  BZ_IO_ERROR
  BZ_MAX_UNUSED
  BZ_MEM_ERROR
  BZ_OK
  BZ_OUTBUFF_FULL
  BZ_PARAM_ERROR
  BZ_RUN
  BZ_RUN_OK
  BZ_SEQUENCE_ERROR
  BZ_STREAM_END
  BZ_UNEXPECTED_EOF

=head1 SEE ALSO

The documentation for zlib, bzip2 and Compress::Zlib.

=head1 AUTHOR

Rob Janes, E<lt>rwjanes at primus.caE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Rob Janes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.


=head1 AUTHOR

The I<Compress::Bzip2> module was originally written by Gawdi Azem
F<azemgi@rupert.informatik.uni-stuttgart.de>.

=head1 MODIFICATION HISTORY

See the Changes file.

2.00 Second public release of I<Compress::Bzip2>.




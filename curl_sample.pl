#!/usr/bin/perl
#use IO::Socket::Socks::Wrapper (
#    Net::HTTP => {
#        ProxyAddr => '127.0.0.1',
#        ProxyPort => 7070,
#        SocksVersion => 4,
        #SocksDebug => 1
#    },
#    Net::HTTPS => {
#        ProxyAddr => '127.0.0.1',
#        ProxyPort => 7070,
#        SocksVersion => 4,
        #SocksDebug => 1
#    }
#);
use LWP;
use Encode;
use Data::Dumper;
use XML::LibXML;

my $url = shift||die "please specify a url";
my $ua = LWP::UserAgent->new;

#my @headers = ('User-Agent' => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; 360SE; 360SE)');

$ua->agent('Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; 360SE; 360SE)');

my $request = HTTP::Request->new(GET => $url);
#$request -> headers(@headers);
my $resp = $ua->simple_request($request);
#print Dumper($resp);
if($resp->status_line =~ m/200/){
    my $content = $resp->content;
    my $prsr = XML::LibXML->new(  # see perldoc XML::LibXML::Parser
            recover             => 2, # makes parser go on despite errors
        );
    my $doc = $prsr->load_html(string => (\$content));
    for my $anchor ( $doc->findnodes("//a[\@href]") ){
        my $line = $anchor->textContent;
        $line =~ s/\&nbsp\;//g;
        my $text = encode("utf-8",$line);
        $text =~ s/^\s*(.*?)\s*$/\1/g;
        $text =~ s/\s+/ /g;
        my $url = $anchor->getAttribute("href");
        printf("text:%s, url:%s\n", $text, $url);
    }
}

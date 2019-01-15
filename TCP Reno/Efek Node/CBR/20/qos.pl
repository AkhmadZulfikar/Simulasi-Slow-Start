    #!/usr/bin/perl -w
    $line=0;
    $send=0;
    $receive=0;
    open(File,$ARGV[0]) or die "Can't Open File";
    #open(File,"../analyzer/upload/one.tr") or die "Can't Open File";
    $starttime=0;
    $stoptime=0;
    $byte=0;
    $count=0;
    while(chomp($line=<File>))
     {
        @arg=split(' ',$line);
        
      
      if($arg[1] eq "-t")
       {
       
        if($arg[0] eq "s")
         {
           if($arg[18] eq "RTR")
            {
              
              $send++;
          #    print "Packet Id:".$arg[40];
           #   print "  send time:".$arg[2];
              $sendtime{$arg[40]}=$arg[2];
              
              if($count==0)
                {
                 $starttime=$arg[2];
                 $count++;
                }
              
            }
         }
         if($arg[0] eq "r")
          {
            if($arg[18] eq "RTR")
             {
                $receivetime{$arg[40]}=$arg[2];
                $receive++;
                $byte+=$arg[36];
           #    print "\nPacket Id:".$arg[40];
           #    print "  Receive time:".$arg[2];
               if($stoptime<$arg[2])
                {
                 $stoptime=$arg[2];
                 }
               
             }
          }
        }
    # For old Wireless Format    
      else
       {
           if($arg[0] eq "s")
            {
             if( $arg[3] eq "AGT")
              {
              $send++;
              $sendtime{$arg[5]}=$arg[1];
              
              if($count==0)
                {
                 $starttime=$arg[1];
                 $count++;
                }
              
              }
             }
           if($arg[0] eq "r")
            {
             if( $arg[3] eq "AGT")
              {
               $receivetime{$arg[5]}=$arg[1];
               $receive++;
               $byte+=$arg[7];
           #    print "\nPacket Id:".$arg[40];
           #   print "  Receive time:".$arg[2];
               if($stoptime<$arg[1])
                {
                 $stoptime=$arg[1];
                 }
               
              }
            }  
               
       }
     
     }
    $delay=0;
    $s=0;
    @difference=();
     foreach $pkid (sort {$a<=>$b} keys %sendtime)
      {
       # print "\n".$pkid." Send Time:".$sendtime{$pkid};
       # print "\n".$pkid." Receive Time:".$receivetime{$pkid};
        
        if( defined($receivetime{$pkid}))
           {
            $delay+=$receivetime{$pkid}-$sendtime{$pkid};
            $difference[$s]=$delay;
           # print "\n".$pkid." Delay:".$delay;
            $s++;
          }
     #  <STDIN>;
      }
    # Jitter Calculation  
    $totaldiff=0;  
    $jittersample=0;
      for($i=0;$i<$s-1;$i++)
       {
          $totaldiff += $difference[$i+1]-$difference[$i];
          $jittersample++;
       }
      
     print "\n\n===========================================================";
     print  "\n\nPacket Sent            : ".$send;
     print  "\n\nPacket Received        : ".$receive;
     print  "\n\nDropped Packets        : ".($send-$receive);
     print  "\n\nPacket Delivery Ratio  : ".(($receive/$send)*100)." %";
     print  "\n\nStart Time             : ".$starttime." s";
     print  "\n\nStop Time              : ".$stoptime." s";
     print  "\n\nTotal bytes            : ".$byte," byte";
     print  "\n\nThroughput             : ".($byte/($stoptime-$starttime))*(8/1024)." kbps";
     print  "\n\nEnd to End Delay       : ".$delay/$s." s";
     print  "\n\nJitter                 : ".$totaldiff/$jittersample." s";
     print "\n\n============================================================";
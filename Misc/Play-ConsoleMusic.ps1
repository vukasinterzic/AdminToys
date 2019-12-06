function Play-ConsoleMusic {
    [CmdletBinding()]

    param 
    (      
        [Parameter()]  
        [ValidateSet('Mario','Tetris','StarWars','MissionImpossible')]
        [string]$Melody
    )

    $MelodyList = @('Mario','Tetris','StarWars','MissionImpossible')

    if ($Melody -eq "") {

        $Melody = $MelodyList | Get-Random
        Write-Host "Melody not selected. Playing random melody: $Melody"
        
    } 

    switch ($Melody) {

        Tetris {
            [Console]::Beep(658, 125);
            [Console]::Beep(1320, 500);
            [Console]::Beep(990, 250);
            [Console]::Beep(1056, 250);
            [Console]::Beep(1188, 250);
            [Console]::Beep(1320, 125);
            [Console]::Beep(1188, 125);
            [Console]::Beep(1056, 250);
            [Console]::Beep(990, 250);
            [Console]::Beep(880, 500);
            [Console]::Beep(880, 250);
            [Console]::Beep(1056, 250);
            [Console]::Beep(1320, 500);
            [Console]::Beep(1188, 250);
            [Console]::Beep(1056, 250);
            [Console]::Beep(990, 750);
            [Console]::Beep(1056, 250);
            [Console]::Beep(1188, 500);
            [Console]::Beep(1320, 500);
            [Console]::Beep(1056, 500);
            [Console]::Beep(880, 500);
            [Console]::Beep(880, 500);
        }

        Mario {
            [System.Console]::Beep(659, 125);
            [System.Console]::Beep(659, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(659, 125);
            [System.Threading.Thread]::Sleep(167);
            [System.Console]::Beep(523, 125);
            [System.Console]::Beep(659, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(784, 125);
            [System.Threading.Thread]::Sleep(375);
            [System.Console]::Beep(392, 125);
            [System.Threading.Thread]::Sleep(375);
            [System.Console]::Beep(523, 125);
            [System.Threading.Thread]::Sleep(250);
            [System.Console]::Beep(392, 125);
            [System.Threading.Thread]::Sleep(250);
            [System.Console]::Beep(330, 125);
            [System.Threading.Thread]::Sleep(250);
            [System.Console]::Beep(440, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(494, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(466, 125);
            [System.Threading.Thread]::Sleep(42);
            [System.Console]::Beep(440, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(392, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(659, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(784, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(880, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(698, 125);
            [System.Console]::Beep(784, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(659, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(523, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(587, 125);
            [System.Console]::Beep(494, 125);
            [System.Threading.Thread]::Sleep(125);
            [System.Console]::Beep(523, 125);
        }

        StarWars {
            [console]::beep(440,500)       
            [console]::beep(440,500) 
            [console]::beep(440,500)        
            [console]::beep(349,350)        
            [console]::beep(523,150)        
            [console]::beep(440,500)        
            [console]::beep(349,350)        
            [console]::beep(523,150)        
            [console]::beep(440,1000) 
            [console]::beep(659,500)        
            [console]::beep(659,500)        
            [console]::beep(659,500)        
            [console]::beep(698,350)        
            [console]::beep(523,150)        
            [console]::beep(415,500)        
            [console]::beep(349,350)        
            [console]::beep(523,150)        
            [console]::beep(440,1000)
        }

        MissionImpossible {
            [console]::beep(784,150) 
            Start-Sleep -m 300 
            [console]::beep(784,150) 
            Start-Sleep -m 300 
            [console]::beep(932,150) 
            Start-Sleep -m 150 
            [console]::beep(1047,150) 
            Start-Sleep -m 150 
            [console]::beep(784,150) 
            Start-Sleep -m 300 
            [console]::beep(784,150) 
            Start-Sleep -m 300 
            [console]::beep(699,150) 
            Start-Sleep -m 150 
            [console]::beep(740,150) 
            Start-Sleep -m 150 
            [console]::beep(784,150) 
            Start-Sleep -m 300 
            [console]::beep(784,150) 
            Start-Sleep -m 300 
            [console]::beep(932,150) 
            Start-Sleep -m 150 
            [console]::beep(1047,150) 
            Start-Sleep -m 150 
            [console]::beep(784,150) 
            Start-Sleep -m 300 
            [console]::beep(784,150) 
            Start-Sleep -m 300 
            [console]::beep(699,150) 
            Start-Sleep -m 150 
            [console]::beep(740,150) 
            Start-Sleep -m 150 
            [console]::beep(932,150) 
            [console]::beep(784,150) 
            [console]::beep(587,1200) 
            Start-Sleep -m 75 
            [console]::beep(932,150) 
            [console]::beep(784,150) 
            [console]::beep(554,1200) 
            Start-Sleep -m 75 
            [console]::beep(932,150) 
            [console]::beep(784,150) 
            [console]::beep(523,1200) 
            Start-Sleep -m 150 
            [console]::beep(466,150) 
            [console]::beep(523,150)
        }

    } #end of Melody switch

}
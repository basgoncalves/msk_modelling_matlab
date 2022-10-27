function myFunction()
bp = 'initial value'; % Assigned *outside* the callback functions so it is "shared" to them
figure
uicontrol( 'Position', [10 35 60 30],'String','Sys(R)','Callback',@(src,evnt)buttonCallback('sys') ); 
uicontrol( 'Position', [10 70 60 30],'String','Mean(B)','Callback',@(src,evnt)buttonCallback('mean')  ); 
uicontrol( 'Position', [10 105 60 30],'String','Dia(G)','Callback',@(src,evnt)buttonCallback('dia') );
uicontrol( 'Position', [100 105 60 30],'String','Print Value','Callback',@(src,evnt)printMyVar );
      function buttonCallback(newString)
          bp = newString;
      end
      function printMyVar()
          disp(bp)
      end
  end
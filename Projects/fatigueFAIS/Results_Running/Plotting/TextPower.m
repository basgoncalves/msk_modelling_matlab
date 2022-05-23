function TextPower(TextPosition,txt,FS)

for ii = 1:length(TextPosition)
    tt = text(TextPosition(ii), max(ylim),txt{ii},'FontSize',FS,'HorizontalAlignment','center',...
        'VerticalAlignment','middle', 'FontName', 'Times New Roman');
end

end

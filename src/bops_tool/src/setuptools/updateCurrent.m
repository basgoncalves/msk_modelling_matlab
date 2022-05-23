function updateCurrent(subject,session)

bops = load_setup_bops;

try subject;
    bops.current.subject = subject;
end


try session;
    bops.current.session = session;
end

xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);
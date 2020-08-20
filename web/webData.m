classdef webData
    %WEBDATA Fetech various kinds of data into ISET
    %   Might wind up being a super-class for various kinds of data, but 
    %   keeping it simple for now.
    
    properties
        dataType; % whether it is Hyperspectral, Multispectral, or HDR
        ourDataStruct;
    end
    
    methods
        function obj = webData(forType)
            %WEBDATA Construct an instance of this class
            %   Detailed explanation goes here
            obj.dataType = forType;
            % not sure if we want one big json file or several, one per
            % type, so no we have one file
            ourData = fileread('webISETData.json');
            obj.ourDataStruct = jsondecode(ourData);
        end
        
        function outputArg = search(obj,ourTags)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            %outputArg = JSON STRUCT FOR FLICKR< WHAT HERE?;   
            ourKeywords = split(ourTags);
            switch obj.dataType
                case 'Hyperspectral'
                    ourDataObject = obj.ourDataStruct.Hyperspectral;
                case 'HDR'
                    ourDataObject = obj.ourDataStruct.HDR;
                otherwise
                    uialert("Data Type not supported.");
            end
            
            for i = 1:length(ourDataObject)
                found = true;
                if isempty(ourDataObject(i).Name) % blank entry
                    found = false;
                else
                    for j = 1: length(ourKeywords)
                        if find(strcmpi(ourDataObject(i).Keywords, ourKeywords(j)))
                        elseif isequal(ourKeywords(j), "")
                            % always match an empty string
                        else
                            found = false;
                        end
                    end
                end
                if found == true
                    if exist('outputArg')
                        % can we just use ourDataObj(i) since it is typed??
                        %outputArg(end+1) = obj.ourDataStruct.Hyperspectral(i);
                        outputArg(end+1) = ourDataObject(i);
                    else
                        outputArg(1) = ourDataObject(i);
                        %outputArg(1) = obj.ourDataStruct.Hyperspectral(i);
                    end
                end
            end
        end
        
        function ourURL = getImageURL(obj, fPhoto, wantSize)
            if isequal(wantSize, 'thumbnail')
                ourURL = fPhoto.Icon;
            else
                ourURL = fPhoto.URL;
            end 
        end
        
        function ourImage = getImage(obj, fPhoto, wantSize)
            ourURL = getImageURL(obj, fPhoto, wantSize);
            ourImage = webread(ourURL);   
        end

    end
end


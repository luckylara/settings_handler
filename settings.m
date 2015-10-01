classdef settings 
% settings class
%
% mySettings = settings('mySettings.yml')
% 
% settingsFile is a yaml file that contains the location
% of the default settings file and the user-settings file. 
%
% default: exampleDefaultSettings.yml
% user: ~/exampleUserSettings.yml

% The default settings file must contain all the relevant
% setting parameters and values for them. The user file
% does not have to exist or may be partially defined. 
%
% If the user requests a setting that exists only in the
% default settings file, then it is read from that file and
% then written to the user file. 
%
% If a setting is changed, the new value is written to the 
% user file. 
%
% Each time a setting is requested, the user file is re-read.
% ADD OPTION TO SUPRESS THIS.


	properties(GetAccess='public', SetAccess='protected')
		defaultFile
		defaultSettings
		userFile
	end

	properties(GetAccess='public', SetAccess='protected')

	end

	properties(GetAccess='public', SetAccess='public')
		userSettings
		paths
	end


	methods
		function obj=settings(settingsFname)
			% constructor
			% read default settings and set up user settings as needed

			if ~exist(settingsFname,'file')
				error('%s does not exits',settingsFname)
			end

			%read the yml file
			Y=yaml.ReadYaml(settingsFname);
			
			if ~exist(Y.default,'file')
				error('Can not find settings file %s\n', Y.default)
			end
			obj.defaultFile = Y.default;
			obj.defaultSettings = yaml.ReadYaml(obj.defaultFile);


			obj.userFile = Y.user;
			if ~exist(obj.userFile)
				%If the user settings file does not exist, we just copy the default settings to the desired location
				fprintf('No user settings file found at %s. Creating default file using %s\n',obj.userFile,obj.defaultFile)
				yaml.WriteYaml(obj.userFile,obj.defaultSettings);
			end

			%Set up the dynamic properties
			[obj.paths,obj.userSettings] = makeEmptyStructAndTree(obj.defaultSettings);
			L=obj.userSettings.findleaves
			obj.userSettings.Node(L)
			fprintf('%d leaves\n',length(L))
			for ii=1:length(L)
				fprintf('LEAF %d\n',L(ii))
				R=obj.userSettings.pathtoroot(L(ii));
				R(end)=[];
				disp(obj.userSettings.Node(R)')
			end
		end 



	end


end






function [out,T,currentBranchNode] = makeEmptyStructAndTree(out,T,currentBranchNode)
	if nargin<2
		f=fields(out);
		T = tree ;
		currentBranchNode = 1;
	end


	f=fields(out);
	%fprintf('\nlooping through %d fields in %s (#%d)\n', length(f), T.Node{currentBranchNode}, currentBranchNode)

	for ii=1:length(f)

		%If we find a structure we will need to add a node
		if isstruct(out.(f{ii}))
			%fprintf('\nBranching at %s', f{ii})
			[T,thisBranch] = T.addnode(currentBranchNode,f{ii});
			[out.(f{ii}),T,~] = makeEmptyStructAndTree(out.(f{ii}),T,thisBranch);
			continue
		end

		%fprintf('Adding %s\n', f{ii})
		[T,~] = T.addnode(currentBranchNode,f{ii});
		out.(f{ii})=[];
	end
end


function p=getStructData(thisStruct,pth)

	for ii=1:length(pth)
		thisStruct=thisStruct.(pth{ii});
	end

	p=thisStruct;
end


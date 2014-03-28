function [frame] = javaui(blockvals)
% javaui.m
% 9/13/13
% Author: Ken Hwang

% Import
import javax.swing.*
import javax.swing.table.*
import java.awt.*
import java.util.Hashtable
import java.lang.Integer

% Set-up JFrame
frame = JFrame('Experiment Info');
callback4 = @(obj,evt)onClose(obj,evt); % Callback for close button
set(frame,'WindowClosingCallback',callback4);
frame.setSize(400,425);
toolkit = Toolkit.getDefaultToolkit();
screenSize = toolkit.getScreenSize();
x = (screenSize.width - frame.getWidth()) / 2;
y = (screenSize.height - frame.getHeight()) / 2;
frame.setLocation(x, y);

%% Tabbed pane 1

% Set-up subject ID entry
tf1Panel = JPanel(GridLayout(1,1));
subjField = JTextField(datestr(now,30));
t1 = BorderFactory.createTitledBorder('Subject ID:');
tf1Panel.setBorder(t1);
tf1Panel.add(subjField);

% Set-up age entry
tf2Panel = JPanel(GridLayout(1,1));
ageField = JTextField();
t2 = BorderFactory.createTitledBorder('Age:');
tf2Panel.setBorder(t2);
tf2Panel.add(ageField);

% Set-up trigger radio buttons
rb2Panel = JPanel(GridLayout(2,1));
t2 = BorderFactory.createTitledBorder('Gender:');
rb2Panel.setBorder(t2);
male = JRadioButton('Male');
male.setActionCommand('Male');
male.setSelected(true);
female = JRadioButton('Female');
female.setActionCommand('Female');

group1 = ButtonGroup();
group1.add(male);
group1.add(female);

rb2Panel.add(male);
rb2Panel.add(female);

% Set-up left pane
left1 = JPanel(GridBagLayout());
left1.setMinimumSize(Dimension(150,275));
left1.setPreferredSize(Dimension(150,275));
gbc = GridBagConstraints();
gbc.fill = GridBagConstraints.HORIZONTAL;
gbc.gridx = 0;
gbc.gridy = 0;
gbc.weightx = 1;
gbc.weighty = .2;
left1.add(tf1Panel,gbc);
gbc.fill = GridBagConstraints.HORIZONTAL;
gbc.gridx = 0;
gbc.gridy = 1;
gbc.weightx = 1;
gbc.weighty = .2;
left1.add(tf2Panel,gbc);
gbc.fill = GridBagConstraints.HORIZONTAL;
gbc.gridx = 0;
gbc.gridy = 2;
gbc.weightx = 1;
gbc.weighty = .6;
left1.add(rb2Panel,gbc);

% Set-up first right panel
btn1Panel = JPanel(GridBagLayout());
gbc = GridBagConstraints();
gbc.gridx = 0;
gbc.gridy = GridBagConstraints.RELATIVE;
t3 = BorderFactory.createTitledBorder('Unused Orders:');
btn1Panel.setBorder(t3);

% Array definition for JTable and run list buttons
headArray = javaArray('java.lang.String',1);
headArray(1) = java.lang.String('Blocks');
listArray = javaArray('java.lang.Object',length(blockvals),1);
btn = cell([length(blockvals) 3]);
callback3 = @(obj,evt)onListSelect(obj,evt);
for i = 1:length(blockvals)
    listArray(i,1) = java.lang.String(blockvals{i});
    btn{i,1} = JButton(blockvals{i});
    btn{i,2} = handle(btn{i,1},'CallbackProperties');
    btn{i,3} = 0; % False flag
    set(btn{i,2},'MouseClickedCallback', callback3);
    btn{i,1}.setEnabled(0);
    btn1Panel.add(btn{i,1}, gbc);
end

% Set-up reset button
resetBtn = JButton('Reset');
rbh = handle(resetBtn,'CallbackProperties');
callback2 = @(obj,evt)onReset(obj,evt);
set(rbh,'MouseClickedCallback', callback2);

% Define JTable
table = JTable();
dataModel = DefaultTableModel(listArray,headArray);
table.setModel(dataModel);
table.setEnabled(0);

% Set-up second right panel
btn2Panel = JPanel(GridBagLayout());
t4 = BorderFactory.createTitledBorder('Block Order:');
btn2Panel.setBorder(t4);
btn2Panel.add(table,gbc);
btn2Panel.add(resetBtn,gbc);

% Set-up entire right pane
right1 = JPanel(GridLayout(1,3));
right1.setMinimumSize(Dimension(250,275));
right1.setPreferredSize(Dimension(250,275));
right1.add(btn1Panel);
right1.add(btn2Panel);

% Set-up confirm button
confirm = JButton('Confirm');
cbh = handle(confirm,'CallbackProperties');
callback1 = @(obj,evt)onConfirm(obj,evt);
set(cbh,'MouseClickedCallback', callback1);

% Set-up exit button
exitBtn = JButton('Exit');
ebh = handle(exitBtn,'CallbackProperties');
set(ebh,'MouseClickedCallback', callback4);

% Set-up bottom pane
bot = JPanel(GridBagLayout());
bot.setMinimumSize(Dimension(400,125));
bot.setPreferredSize(Dimension(400,125));
gbc = GridBagConstraints();
gbc.fill = GridBagConstraints.BOTH;
gbc.weightx = 1;
gbc.weighty = 1;
gbc.insets.top = 25;
gbc.insets.bottom = 25;
gbc.insets.left = 25;
gbc.insets.right = 25;
bot.add(confirm,gbc);
bot.add(exitBtn,gbc);

% Split left and right
splitpane1 = JSplitPane(JSplitPane.HORIZONTAL_SPLIT,left1,right1);
splitpane1.setEnabled(false);

% Split top and bottom
splitpane2 = JSplitPane(JSplitPane.VERTICAL_SPLIT,splitpane1,bot);
splitpane2.setEnabled(false);

%% Tabbed pane 2

labelTextCell = cell([10 4]); % 10 ticks
labelTextCell(:,1) = cellfun(@(y)(num2str(y,'%1.2f')),num2cell(.15:.15:1.5),'UniformOutput',false);
labelTextCell(:,2) = cellfun(@(y)(num2str(y,'%1.2f')),num2cell(.06:.06:.6),'UniformOutput',false);
labelTextCell(:,3) = cellfun(@(y)(num2str(y,'%1.2f')),num2cell(.8:.8:8),'UniformOutput',false);
labelTextCell(:,4) = cellfun(@(y)(num2str(y,'%1.2f')),num2cell(.2:.2:2),'UniformOutput',false);
sliderLabelText = 'Duration (seconds): ';
panelText = {'Picture 1','Mask','Picture 2','Fixation'};

for i = 1:4
       
    % Panel
    tempPanel = JPanel(GridBagLayout());
    gbc = GridBagConstraints();
    gbc.fill = GridBagConstraints.HORIZONTAL;
    
    % Text label
    tempSliderLabel = JLabel(sliderLabelText, JLabel.CENTER);
    
    % Slider
    tempSlider = JSlider(JSlider.HORIZONTAL,1,10,5);
    
    % Slider callbacks
    tempSlider = handle(javaObjectEDT(tempSlider), 'CallbackProperties');
    
    % Slider ticks
    tempLabelTabel = Hashtable();
    for ii = 1:10
        tempLabelTabel.put(Integer(ii),JLabel(labelTextCell{ii,i}) );
    end
    tempSlider.setLabelTable(tempLabelTabel);
    tempSlider.setPaintLabels(true);
    tempSlider.setMajorTickSpacing(10);
    tempSlider.setMinorTickSpacing(1);
    tempSlider.setPaintTicks(true);
    tempSlider.setSnapToTicks(true);
    
    % Panel set-up
    tempPanel.setBorder(BorderFactory.createTitledBorder(panelText{i}));
    gbc.fill = GridBagConstraints.HORIZONTAL;
    gbc.gridx = 0;
    gbc.gridy = 0;
    gbc.weighty = .1;
    gbc.weightx = 1.0;
    tempPanel.add(tempSliderLabel,gbc);
    gbc.fill = GridBagConstraints.HORIZONTAL;
    gbc.gridx = 0;
    gbc.gridy = 1;
    gbc.weighty = .9;
    gbc.weightx = 1.0;
    tempPanel.add(tempSlider,gbc);
    
    if i == 1
        p1Panel = tempPanel;
        p1Slider = tempSlider;
        set(p1Slider,'StateChangedCallback',@label1Change);
        label1Table = tempLabelTabel;
        sliderLabel1 = tempSliderLabel;
    elseif i == 2
        maskPanel = tempPanel;
        maskSlider = tempSlider;
        set(maskSlider,'StateChangedCallback',@label2Change);
        label2Table = tempLabelTabel;
        sliderLabel2 = tempSliderLabel;
    elseif i == 3
        p2Panel = tempPanel;
        p2Slider = tempSlider;
        set(p2Slider,'StateChangedCallback',@label3Change);
        label3Table = tempLabelTabel;
        sliderLabel3 = tempSliderLabel;
    elseif i == 4
        fixPanel = tempPanel;
        fixSlider = tempSlider;
        set(fixSlider,'StateChangedCallback',@label4Change);
        label4Table = tempLabelTabel;
        sliderLabel4 = tempSliderLabel;
    end
end

% Set-up left pane
left2 = JPanel(GridLayout(4,1));
left2.setMinimumSize(Dimension(275,325));
left2.setPreferredSize(Dimension(275,325));
left2.add(p1Panel);
left2.add(maskPanel);
left2.add(p2Panel);
left2.add(fixPanel);

% Set defaults, activate state change
p1Slider.setValue(6);
maskSlider.setValue(6);
p2Slider.setValue(6);
fixSlider.setValue(6);
setSliderDefaults();

% Create the label that displays the animation.
picture = JLabel();
picture.setMinimumSize(Dimension(215,175));
picture.setPreferredSize(Dimension(215,175));
picture.setHorizontalAlignment(JLabel.CENTER);
picture.setAlignmentX(Component.CENTER_ALIGNMENT);
picture.setBorder(BorderFactory.createCompoundBorder(BorderFactory.createLoweredBevelBorder(),BorderFactory.createEmptyBorder(10,10,10,10)));

% Button to play sequence
playBtn = JButton('Play');
pbh = handle(playBtn,'CallbackProperties');
callback5 = @(obj,evt)onPlay(obj,evt);
set(pbh,'MouseClickedCallback', callback5);

% Button to reset defaults
defaultBtn = JButton('Defaults');
dbh = handle(defaultBtn,'CallbackProperties');
callback6 = @(obj,evt)setSliderDefaults(obj,evt);
set(dbh,'MouseClickedCallback', callback6);

% Set-up right pane
right2 = JPanel(GridBagLayout());
t5 = BorderFactory.createTitledBorder('Preview:');
right2.setBorder(t5);
right2.setMinimumSize(Dimension(125,325));
right2.setPreferredSize(Dimension(125,325));
gbc = GridBagConstraints();
gbc.fill = GridBagConstraints.HORIZONTAL;
gbc.gridx = 0;
gbc.gridy = 0;
gbc.weighty = .8;
right2.add(picture,gbc);
gbc.gridx = 0;
gbc.gridy = 1;
gbc.weightx = .1;
right2.add(playBtn,gbc);
gbc.gridx = 0;
gbc.gridy = 2;
gbc.weightx = .1;
right2.add(defaultBtn,gbc);

% Set-up split pane
splitpane3 = JSplitPane(JSplitPane.HORIZONTAL_SPLIT,left2,right2);
splitpane3.setEnabled(false);

% Put tabbed pane together
tabbedPane = JTabbedPane();
tabbedPane.addTab('Main', [], splitpane2,'Main experimental settings');
tabbedPane.addTab('Trial', [], splitpane3,'Trial experimental settings');
                  
frame.add(tabbedPane);

frame.setResizable(0);
frame.setVisible(1);

    function setSliderDefaults(src,evt)
        % Set defaults
        p1Slider.setValue(5);
        maskSlider.setValue(5);
        p2Slider.setValue(5);
        fixSlider.setValue(5);
    end

    function label1Change(src,evt)
        import java.lang.Integer
        val = javaMethodEDT('getValue',src);
        jLabel = javaMethodEDT('get',label1Table,Integer(val));
        val = javaMethodEDT('getText',jLabel);
        javaMethodEDT('setText',sliderLabel1,[sliderLabelText char(val)]);
    end

    function label2Change(src,evt)
        import java.lang.Integer
        val = javaMethodEDT('getValue',src);
        jLabel = javaMethodEDT('get',label2Table,Integer(val));
        val = javaMethodEDT('getText',jLabel);
        javaMethodEDT('setText',sliderLabel2,[sliderLabelText char(val)]);
    end

    function label3Change(src,evt)
        import java.lang.Integer
        val = javaMethodEDT('getValue',src);
        jLabel = javaMethodEDT('get',label3Table,Integer(val));
        val = javaMethodEDT('getText',jLabel);
        javaMethodEDT('setText',sliderLabel3,[sliderLabelText char(val)]);
    end

    function label4Change(src,evt)
        import java.lang.Integer
        val = javaMethodEDT('getValue',src);
        jLabel = javaMethodEDT('get',label4Table,Integer(val));
        val = javaMethodEDT('getText',jLabel);
        javaMethodEDT('setText',sliderLabel4,[sliderLabelText char(val)]);
    end

    function onPlay(obj,evt)
        import javax.swing.ImageIcon
        import java.lang.Integer
        
        p = mfilename('fullpath');
        f = fileparts(fileparts(p)); % In ../bin
        
        paths = {['content' filesep 'bodies' filesep 'WHR_0.66.jpg'], ...
            ['content' filesep 'general' filesep 'mask.jpg'], ...
            ['content' filesep 'bodies' filesep 'WHR_0.66.jpg'], ...
            ['content' filesep 'general' filesep 'fix.jpg']};
        imgIcon = cell([4 1]);
        waitvals = zeros([4 1]);
        for imgIndex = 1:4
            I = imread([f filesep paths{imgIndex}]);
            I = imresize(I,[215, 175]);
            jimage = im2java(I);
            imgIcon{imgIndex} = ImageIcon(jimage);
            
            switch imgIndex
                case 1
                    tempLabel = sliderLabel1;
                case 2
                    tempLabel = sliderLabel2;
                case 3
                    tempLabel = sliderLabel3;
                case 4
                    tempLabel = sliderLabel4;
            end
            
            val = javaMethodEDT('getText',tempLabel);
            waitvals(imgIndex) = str2double(regexp(char(val),'\d{1,1}.\d{2,2}','match'));
        end
        
        for imgDisp = 1:4
            picture.setIcon(imgIcon{imgDisp});
            pause(waitvals(imgDisp));        
        end
        picture.setIcon([]);
        picture.revalidate;
    end

    function onListSelect(obj,evt) % When a run list button is pressed
        btn_txt = obj.get.Label();
        btn_index = strcmp(blockvals,btn_txt);
        if btn{btn_index,3} % Only if flag is set true
            btn{btn_index,1}.setEnabled(0);
            list_index = find(cellfun(@isempty,cell(listArray)),1);
            listArray(list_index,1) = java.lang.String(btn_txt); % Modify list array
            dataModel.addRow(java.lang.String(btn_txt)); % Add row
            btn{btn_index,3} = 0; % Set false flag
        else
        end
    end

    function onReset(obj,evt) % Whem the reset button is pressed
        dataModel.setRowCount(0); % Clear table
        listArray = [];
        listArray = javaArray('java.lang.Object',length(blockvals),1); % Re-initialize listArray
        for j = 1:size(btn,1); % Reset run list buttons and set flags true
            btn{j,1}.setEnabled(1);
            btn{j,3} = 1;
        end
    end

    function onConfirm(obj,evt) % When confirm button is pressed
        sid = subjField.getText();
        age = ageField.getText();
        selectedModel1 = group1.getSelection();
        gender = selectedModel1.getActionCommand();
        listout = cell(listArray);
        
        if isempty(char(sid)) % Check for empty SID
            javax.swing.JOptionPane.showMessageDialog(frame,'Subject ID is empty!','Subject ID check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
        elseif isempty(char(age)) % Check for empty SID
            javax.swing.JOptionPane.showMessageDialog(frame,'Age field is empty!','Age check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
        elseif any(cellfun(@isempty,listout)) % Check for empty entries in order list
            javax.swing.JOptionPane.showMessageDialog(frame,'There are unused blocks!','Block order check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
        else
            
            % Parameter confirmation
            s = [];
            for k = 1:length(listout)
                s = [s 'Block ' int2str(k) ': ' listout{k} '\n'];
            end
            
            infostring = sprintf(['Subject ID: ' char(sid) ...
                '\nAge: ' char(age) ...
                '\nGender: ' char(gender) ...
                '\n\nOrder: \n' s(1:end-2) ...
                '\n\nIs this correct?']);
            result = javax.swing.JOptionPane.showConfirmDialog(frame,infostring,'Confirm parameters',javax.swing.JOptionPane.YES_NO_OPTION);
            
            % Record data and close
            if result==javax.swing.JOptionPane.YES_OPTION
                                
                waitvals(1) = str2double(regexp(char(javaMethodEDT('getText',sliderLabel1)),'\d{1,1}.\d{2,2}','match'));
                waitvals(2) = str2double(regexp(char(javaMethodEDT('getText',sliderLabel2)),'\d{1,1}.\d{2,2}','match'));
                waitvals(3) = str2double(regexp(char(javaMethodEDT('getText',sliderLabel3)),'\d{1,1}.\d{2,2}','match'));
                waitvals(4) = str2double(regexp(char(javaMethodEDT('getText',sliderLabel4)),'\d{1,1}.\d{2,2}','match'));
                
                setappdata(frame,'UserData',{char(sid),char(age),char(gender),listout,waitvals});
                frame.dispose();
            else
            end
        end
    end

    function onClose(obj,evt) % When close button on frame is pressed
        setappdata(frame,'UserData',[]);
        frame.setVisible(0);
        frame.dispose();
    end
end
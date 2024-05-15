import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? note;
  
  const NoteEditorPage({
    super.key,
    this.note,
  });

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();
  
  String _selectedCategory = 'Personal';
  List<String> _tags = [];
  Color _selectedColor = Colors.blue;
  bool _isPinned = false;
  bool _isRichText = false;
  bool _isVoiceRecording = false;

  final List<String> _categories = ['Personal', 'Work', 'Ideas', 'Study', 'Shopping'];
  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'];
      _contentController.text = widget.note!['content'];
      _selectedCategory = widget.note!['category'];
      _tags = List<String>.from(widget.note!['tags']);
      _selectedColor = widget.note!['color'];
      _isPinned = widget.note!['isPinned'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: _togglePin,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Title Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _titleController,
              focusNode: _titleFocus,
              decoration: const InputDecoration(
                hintText: 'Note title...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Content Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _contentController,
                focusNode: _contentFocus,
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
          
          // Bottom Toolbar
          _buildBottomToolbar(),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // Tags
          if (_tags.isNotEmpty) _buildTagsRow(),
          
          // Toolbar
          Row(
            children: [
              // Category
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Color Picker
              _buildColorPicker(),
              
              const SizedBox(width: 16),
              
              // Voice Recording
              IconButton(
                icon: Icon(
                  _isVoiceRecording ? Icons.mic : Icons.mic_none,
                  color: _isVoiceRecording ? Colors.red : Colors.grey,
                ),
                onPressed: _toggleVoiceRecording,
              ),
              
              // Add Tag
              IconButton(
                icon: const Icon(Icons.tag),
                onPressed: _addTag,
              ),
              
              // Rich Text
              IconButton(
                icon: Icon(
                  _isRichText ? Icons.format_bold : Icons.format_bold_outlined,
                ),
                onPressed: _toggleRichText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        children: _tags.map((tag) {
          return Chip(
            label: Text(tag),
            onDeleted: () => _removeTag(tag),
            deleteIcon: const Icon(Icons.close, size: 16),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _colors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedColor == color ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
    });
  }

  void _toggleVoiceRecording() {
    setState(() {
      _isVoiceRecording = !_isVoiceRecording;
    });
    
    if (_isVoiceRecording) {
      _startVoiceRecording();
    } else {
      _stopVoiceRecording();
    }
  }

  void _toggleRichText() {
    setState(() {
      _isRichText = !_isRichText;
    });
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController tagController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: tagController,
            decoration: const InputDecoration(
              hintText: 'Enter tag name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final tag = tagController.text.trim();
                if (tag.isNotEmpty && !_tags.contains(tag)) {
                  setState(() {
                    _tags.add(tag);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _startVoiceRecording() {
    // Implement voice recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording started...')),
    );
  }

  void _stopVoiceRecording() {
    // Implement voice recording stop
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording stopped')),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Save Note'),
              onTap: _saveNote,
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Note'),
              onTap: _shareNote,
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate Note'),
              onTap: _duplicateNote,
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Note'),
              onTap: _deleteNote,
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    
    // Implement note saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved')),
    );
    Navigator.pop(context);
  }

  void _shareNote() {
    // Implement note sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note shared')),
    );
  }

  void _duplicateNote() {
    // Implement note duplication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note duplicated')),
    );
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

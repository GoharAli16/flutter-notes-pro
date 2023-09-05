import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Date Modified';

  final List<Map<String, dynamic>> _notes = [
    {
      'id': '1',
      'title': 'Meeting Notes - Project Planning',
      'content': 'Discussed the new mobile app features and timeline. Key points:\n- User authentication system\n- Real-time notifications\n- Offline support\n- Performance optimization',
      'category': 'Work',
      'createdAt': '2024-01-15',
      'modifiedAt': '2024-01-15',
      'isPinned': true,
      'tags': ['meeting', 'project', 'planning'],
      'color': Colors.blue,
    },
    {
      'id': '2',
      'title': 'Shopping List',
      'content': 'Grocery shopping for the week:\n- Milk\n- Bread\n- Eggs\n- Vegetables\n- Fruits',
      'category': 'Personal',
      'createdAt': '2024-01-14',
      'modifiedAt': '2024-01-14',
      'isPinned': false,
      'tags': ['shopping', 'grocery'],
      'color': Colors.green,
    },
    {
      'id': '3',
      'title': 'Ideas for Blog Post',
      'content': 'Topic: Flutter Development Best Practices\n\nOutline:\n1. State Management\n2. Performance Optimization\n3. Testing Strategies\n4. Code Organization',
      'category': 'Ideas',
      'createdAt': '2024-01-13',
      'modifiedAt': '2024-01-13',
      'isPinned': false,
      'tags': ['blog', 'flutter', 'development'],
      'color': Colors.orange,
    },
  ];

  final List<String> _categories = ['All', 'Work', 'Personal', 'Ideas', 'Study'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          
          // Category Filter
          _buildCategoryFilter(),
          
          // Notes List
          Expanded(
            child: _buildNotesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotesList() {
    final filteredNotes = _getFilteredNotes();
    
    if (filteredNotes.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty ? 'No notes found' : 'No notes yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Try a different search term'
                : 'Create your first note to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createNote,
              icon: const Icon(Icons.add),
              label: const Text('Create Note'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openNote(note),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (note['isPinned'])
                    const Icon(
                      Icons.push_pin,
                      size: 16,
                      color: Colors.orange,
                    ),
                  if (note['isPinned']) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note['title'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'pin',
                        child: Text('Pin/Unpin'),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) => _handleNoteAction(value, note),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Content Preview
              Text(
                note['content'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Footer
              Row(
                children: [
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: note['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      note['category'],
                      style: TextStyle(
                        color: note['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Tags
                  if (note['tags'].isNotEmpty) ...[
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        children: (note['tags'] as List<String>).take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Date
                  Text(
                    _formatDate(note['modifiedAt']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredNotes() {
    var filtered = _notes.where((note) {
      // Category filter
      if (_selectedCategory != 'All' && note['category'] != _selectedCategory) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return note['title'].toLowerCase().contains(query) ||
               note['content'].toLowerCase().contains(query) ||
               (note['tags'] as List<String>).any((tag) => 
                   tag.toLowerCase().contains(query));
      }
      
      return true;
    }).toList();
    
    // Sort notes
    filtered.sort((a, b) {
      if (a['isPinned'] && !b['isPinned']) return -1;
      if (!a['isPinned'] && b['isPinned']) return 1;
      
      switch (_sortBy) {
        case 'Date Modified':
          return b['modifiedAt'].compareTo(a['modifiedAt']);
        case 'Date Created':
          return b['createdAt'].compareTo(a['createdAt']);
        case 'Title':
          return a['title'].compareTo(b['title']);
        case 'Category':
          return a['category'].compareTo(b['category']);
        default:
          return 0;
      }
    });
    
    return filtered;
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _toggleSearch() {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort Notes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...['Date Modified', 'Date Created', 'Title', 'Category'].map((option) {
              return ListTile(
                title: Text(option),
                trailing: Radio(
                  value: option,
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            }),
          ],
        ),
      ),
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
              leading: const Icon(Icons.folder),
              title: const Text('Manage Categories'),
              onTap: _manageCategories,
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup Notes'),
              onTap: _backupNotes,
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore Notes'),
              onTap: _restoreNotes,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: _openSettings,
            ),
          ],
        ),
      ),
    );
  }

  void _createNote() {
    // Implement note creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating new note...')),
    );
  }

  void _openNote(Map<String, dynamic> note) {
    // Implement note opening
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${note['title']}...')),
    );
  }

  void _handleNoteAction(String action, Map<String, dynamic> note) {
    switch (action) {
      case 'edit':
        _openNote(note);
        break;
      case 'pin':
        setState(() {
          note['isPinned'] = !note['isPinned'];
        });
        break;
      case 'duplicate':
        // Implement note duplication
        break;
      case 'delete':
        _deleteNote(note);
        break;
    }
  }

  void _deleteNote(Map<String, dynamic> note) {
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
              setState(() {
                _notes.removeWhere((n) => n['id'] == note['id']);
              });
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

  void _manageCategories() {
    // Implement category management
  }

  void _backupNotes() {
    // Implement note backup
  }

  void _restoreNotes() {
    // Implement note restore
  }

  void _openSettings() {
    // Implement settings
  }
}

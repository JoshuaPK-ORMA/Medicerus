import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../data/moor_database.dart';
import 'widget/new_tag_input_widget.dart';
import 'widget/new_task_input_widget.dart';
import 'widget/add_rc_item_input_widget.dart';

class RapidchartPage extends StatefulWidget {
  @override
  _RapidchartPageState createState() => _RapidchartPageState();
}

class _RapidchartPageState extends State<RapidchartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('RapidChart'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: _buildTaskList(context)),
            //NewTaskInput(),
            //NewTagInput(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
        // #JPK #LearningDart: https://github.com/AbdulRahmanAlHamali/flutter_pagewise/issues/63#issuecomment-587512197
        // onPressed: _showAddItemSheet(context),
          onPressed: () => _showAddItemSheet(context),
          tooltip: 'Add Item',
          child: Icon(Icons.add),
        )
    );
  }

  _showAddItemSheet(var context)
  {
    showBottomSheet(
        context: context,
        builder: (context) => Container(
          color: Colors.lightBlue[50],
          child: AddRapidchartItemInput(),
        ));
  }

  StreamBuilder<List<TaskWithTag>> _buildTaskList(BuildContext context) {
    final dao = Provider.of<TaskDao>(context);
    return StreamBuilder(
      stream: dao.watchAllTasks(),
      builder: (context, AsyncSnapshot<List<TaskWithTag>> snapshot) {
        final tasks = snapshot.data ?? List();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (_, index) {
            final item = tasks[index];
            return _buildListItem(item, dao);
          },
        );
      },
    );
  }

  Widget _buildListItem(TaskWithTag item, TaskDao dao) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => dao.deleteTask(item.task),
        )
      ],
      child: CheckboxListTile(
        title: Text(item.task.name),
        subtitle: Text(item.task.dueDate?.toString() ?? 'No date'),
        secondary: _buildTag(item.tag),
        value: item.task.completed,
        onChanged: (newValue) {
          dao.updateTask(item.task.copyWith(completed: newValue));
        },
      ),
    );
  }

  Column _buildTag(Tag tag) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (tag != null) ...[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(tag.color),
            ),
          ),
          Text(
            tag.name,
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../validation.dart';
import 'shared.dart';

class RecipeForm extends StatefulWidget {
  const RecipeForm({
    super.key,
    this.initial,
    required this.onSubmit,
    required this.submitLabel,
    this.onCancel,
  });
  final RecipeDraft? initial;
  final Future<void> Function(RecipeDraft) onSubmit;
  final String submitLabel;
  final VoidCallback? onCancel;
  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _cookTime = TextEditingController(
    text: widget.initial?.cookTime.toString() ?? '',
  );
  late final _servings = TextEditingController(
    text: widget.initial?.servings?.toString() ?? '',
  );
  late final _notes = TextEditingController(text: widget.initial?.notes ?? '');
  late String? _category = widget.initial?.category;
  late String? _difficulty = widget.initial?.difficulty;
  bool _submitted = false;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await widget.onSubmit(
        RecipeDraft(
          name: _name.text,
          category: _category!,
          difficulty: _difficulty!,
          cookTime: int.parse(_cookTime.text.trim(), radix: 10),
          servings: int.tryParse(_servings.text.trim(), radix: 10),
          notes: _notes.text,
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = friendlyError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _cookTime.dispose();
    _servings.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    autovalidateMode: _submitted
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _name,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          validator: Validators.name,
        ),

        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          initialValue: _category ?? '',
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Category'),
          items: [
            const DropdownMenuItem(value: '', child: Text('Choose category')),
            ...categories.map(
              (value) => DropdownMenuItem(value: value, child: Text(value)),
            ),
          ],
          onChanged: _busy
              ? null
              : (value) => setState(() => _category = value),
          validator: (value) => value == null || value.isEmpty
              ? 'Please choose a category'
              : null,
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          initialValue: _difficulty ?? '',
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Difficulty'),
          items: [
            const DropdownMenuItem(value: '', child: Text('Choose difficulty')),
            ...difficulties.map(
              (value) => DropdownMenuItem(value: value, child: Text(value)),
            ),
          ],
          onChanged: _busy
              ? null
              : (value) => setState(() => _difficulty = value),
          validator: (value) => value == null || value.isEmpty
              ? 'Please choose a difficulty'
              : null,
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _cookTime,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: 'Cook time (minutes)'),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: Validators.cookTime,
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _servings,
          enabled: !_busy,
          decoration: const InputDecoration(
            labelText: 'Servings (optional)',
            hintText: '1 to 20',
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: Validators.servings,
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _notes,
          enabled: !_busy,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            hintText: 'Ingredients or cooking tips',
            alignLabelWithHint: true,
          ),
          minLines: 2,
          maxLines: 6,
          validator: Validators.notes,
        ),
        const SizedBox(height: 22),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.submitLabel),
        ),
        if (widget.onCancel != null) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _busy ? null : widget.onCancel,
            child: const Text('Cancel'),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 14),
          InlineNotice(_error!, error: true),
        ],
      ],
    ),
  );
}

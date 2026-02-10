# name: discourse-ai-encoding-fixer
# about: Force le nettoyage des traductions IA (\n, \u003e) avant mise en base
# version: 1.0
# authors: JesusBYS

after_initialize do
  # On écoute l'événement système de modification des champs personnalisés
  on(:post_custom_field_changed) do |name, value, post|
    # Les traductions Discourse AI utilisent des clés commençant par 'translated_text_'
    if name.start_with?("translated_text_") && value.is_a?(String)
      
      # 1. On nettoie les doubles échappements caractéristiques du JSON mal parsé
      # On utilise une regex pour cibler les séquences littérales \n et \u003e
      cleaned_value = value.gsub(/\\n/, "\n")
                           .gsub(/\\u003e/, ">")
                           .gsub('\n', "\n")
                           .gsub('\u003e', ">")

      # 2. Si la valeur a changé, on la met à jour proprement en évitant une boucle infinie
      if cleaned_value != value
        # On met à jour directement en SQL pour court-circuiter les hooks qui pourraient boucler
        PostCustomField.where(id: post.custom_fields_by_name[name]&.first&.id)
                       .update_all(value: cleaned_value) if post.custom_fields_by_name[name]
        
        # On met aussi à jour l'objet en mémoire pour l'affichage immédiat
        post.custom_fields[name] = cleaned_value
      end
    end
  end
end

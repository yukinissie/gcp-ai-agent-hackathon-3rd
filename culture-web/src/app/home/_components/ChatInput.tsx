import { Flex, TextField, Button } from '@radix-ui/themes';
import { ChatInputProps } from './chatTypes';

export function ChatInput({ onSendMessage, disabled = false, placeholder = "メッセージを入力..." }: ChatInputProps) {
  
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const form = e.target as HTMLFormElement;
    const formData = new FormData(form);
    const input = formData.get('message') as string;
    
    if (input?.trim() && !disabled) {
      onSendMessage(input.trim());
      form.reset();
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ width: '100%' }}>
      <Flex gap="2" align="center">
        <TextField.Root
          name="message"
          placeholder={placeholder}
          disabled={disabled}
          style={{ flex: 1 }}
          size="2"
        />
        <Button
          type="submit"
          disabled={disabled}
          variant="solid"
          size="2"
        >
          送信
        </Button>
      </Flex>
    </form>
  );
}

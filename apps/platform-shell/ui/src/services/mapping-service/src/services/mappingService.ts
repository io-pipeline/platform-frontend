import { createClient } from '@connectrpc/connect';
import { createBinaryTransport } from '@ai-pipestream/grpc-stubs';
import { MappingService } from '@ai-pipestream/grpc-stubs/mapping';
import type { ApplyMappingRequest, ApplyMappingResponse } from '@ai-pipestream/grpc-stubs/mapping';

const transport = createBinaryTransport(`http://${window.location.hostname}:37200`);

const client = createClient(MappingService, transport);

export const mappingService = {
  applyMapping(request: ApplyMappingRequest): Promise<ApplyMappingResponse> {
    return client.applyMapping(request);
  },
};
